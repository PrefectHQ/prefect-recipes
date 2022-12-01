"""
Merge multiple dependabot pull requests across multiple repositories:
1. Queries ten pull requests (PR) in the repository
2. For each PR, check if the title matches with the provided title
3. Automatically approve the PR if there's a matching PR
4. Leave "@dependabot merge" which will merge the PR if all tests pass
To create a deployment:
```
prefect deployment build merge_dependabot_pull_requests.py:merge_dependabot_pull_requests --name for_prefect_collections
prefect deployment apply merge_dependabot_pull_requests-deployment.yaml
```

Pre-requisites:
`pip install prefect prefect-github` and an existing `GitHubCredentials` block created and noted
"""  # noqa


import base64
from datetime import timedelta
from pathlib import Path
from typing import Any, Dict, List

import httpx
import yaml
from prefect import flow, get_run_logger, task
from prefect.tasks import task_input_hash

from prefect_github import GitHubCredentials
from prefect_github.mutations import add_comment_subject, add_pull_request_review
from prefect_github.repository import (
    query_repository_pull_request,
    query_repository_pull_requests,
)

BLOCK_NAME = "merge-dependabot-token"
REPOSITORY_OWNER = "PrefectHQ"
DEPENDABOT_PULL_REQUEST_TITLE = "Bump actions/add-to-project from 0.3.0 to 0.4.0"


@task(
    cache_key_fn=task_input_hash,
    cache_expiration=timedelta(days=1),
    retries=3,
    retry_delay_seconds=10,
)
def get_repository_names(
    github_credentials: GitHubCredentials,
) -> List[str]:
    """
    Get a list of repository names, maintained by Prefect, by scraping
    https://github.com/PrefectHQ/prefect/tree/main/docs/collections/catalog.

    Note, this whole task can be rewritten as needed to collect the desired repository names,
    or completely disregard this task and manually specify a list of repositories below.

    Args:
        github_credentials: GitHubCredentials block from prefect-github that stores a PAT.
    
    Returns:
        List of repository names, e.g. ["prefect-aws", "prefect-gcp"].
    """
    token = github_credentials.token.get_secret_value()
    tree_url = (
        "https://api.github.com/repos/prefecthq/prefect/git/trees/main?recursive=1"
    )
    headers = {"Authorization": f"Bearer {token}"}
    tree_contents = httpx.get(tree_url, headers=headers).json()["tree"]

    repositories = []
    for tree in tree_contents:
        path = tree["path"]
        # here, since we're scraping docs/collections/catalog
        # we subset and pin down the results with prefect-
        # if not, it picks up TEMPLATE.yaml
        if path.startswith("docs/collections") and "prefect-" in path:
            url_contents = httpx.get(tree["url"], headers=headers).json()
            path_contents = base64.b64decode(url_contents["content"]).decode()
            author = yaml.safe_load(path_contents)["author"]
            if author == "Prefect":
                repository = Path(path).stem.split("/")[-1]
                repositories.append(repository)

    return repositories


@flow
def merge_dependabot_pull_request(
    github_credentials: GitHubCredentials,  # block type
    repository_name: str,
    repository_owner: str,
    pull_request_title: str,
) -> Dict[str, Any]:
    """
    1. Queries ten pull requests (PR) in the repository.
    2. For each PR, check if the title matches with the provided title.
    3. Automatically approve the PR if there's a matching PR.
    4. Leave "@dependabot merge" which will merge the PR if all tests pass.

    Args:
        github_credentials: GitHubCredentials block from prefect-github that stores a PAT.
        repository_name: The name of the repository.
        repository_owner: The owner / organization of the repository.
        pull_request_title: The name of the pull request to merge.

    Returns:
        The metadata about the pull request.
    """
    logger = get_run_logger()
    logger.info(f"Locating {pull_request_title} PR for {repository_name}...")

    # subset pull requests by labels
    repository_kwargs = dict(
        name=repository_name,
        owner=repository_owner,
        github_credentials=github_credentials,
    )
    number_nodes = query_repository_pull_requests(
        states=["OPEN"],
        labels=["github_actions", "dependencies"],
        return_fields=["number"],
        first=10,
        **repository_kwargs,
    )["nodes"]  # returned GraphQL nodes

    # find the pull request that matches the provided title
    for number_node in number_nodes:
        pull_request = query_repository_pull_request(
            number=number_node["number"], **repository_kwargs
        )
        if pull_request["title"] == pull_request_title:
            pull_request_id = pull_request["id"]
            break
    else:
        raise ValueError(
            f"No pull requests found in {repository_name} "
            f"that match: {pull_request_title}"
        )

    # automatically approve the pull request
    pull_request_review = add_pull_request_review(
        pull_request_id=pull_request_id,
        github_credentials=github_credentials,
        event="APPROVE",
        body="Approval done through a prefect-github flow!",
        return_fields=["id"],
    )

    # this will merge the PR if all checks pass
    add_comment_subject(
        subject_id=pull_request_id,
        body="@dependabot merge",
        github_credentials=github_credentials,
        wait_for=[pull_request_review],
    )
    return pull_request


@flow
def merge_dependabot_pull_requests(
    block_name: str = BLOCK_NAME,
    repository_owner: str = REPOSITORY_OWNER,
    pull_request_title: str = DEPENDABOT_PULL_REQUEST_TITLE,
) -> Dict:
    """
    Merge multiple dependabot pull requests across multiple repositories.

    Args:
        block_name: The name of the GitHubCredentials block to load.
        repository_owner: The owner / organization of the repository.
        pull_request_title: The name of the pull request to merge.
    
    Returns:
        A mapping of repository names to the pull request state, e.g. success.
    """
    github_credentials = GitHubCredentials.load(block_name)
    repository_names = get_repository_names(
        github_credentials=github_credentials
    )

    repository_pull_request_states = {}
    for repository_name in repository_names:
        flow_name = f"merge_dependabot_pull_request_in_{repository_name}"
        pull_request_state = merge_dependabot_pull_request.with_options(name=flow_name)(
            github_credentials=github_credentials,
            repository_name=repository_name,
            repository_owner=repository_owner,
            pull_request_title=pull_request_title,
            return_state=True,
        )
        repository_pull_request_states[repository_name] = pull_request_state
    return repository_pull_request_states


if __name__ == "__main__":
    merge_dependabot_pull_requests(
        block_name=BLOCK_NAME,
        repository_owner=REPOSITORY_OWNER,
        pull_request_title=DEPENDABOT_PULL_REQUEST_TITLE,
    )
