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
`pip install prefect prefect-github`
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
COLLECTION_AUTHOR = "Prefect"
DEPENDABOT_PULL_REQUEST_TITLE = "Bump actions/add-to-project from 0.3.0 to 0.4.0"


@task(
    cache_key_fn=task_input_hash,
    cache_expiration=timedelta(days=1),
    retries=3,
    retry_delay_seconds=10,
)
def get_collection_names(
    github_credentials: GitHubCredentials, collection_author: str
) -> List[str]:
    """
    Get a list of collection names, maintained by Prefect, by scraping
    https://github.com/PrefectHQ/prefect/tree/main/docs/collections/catalog.
    """
    token = github_credentials.token.get_secret_value()
    tree_url = (
        "https://api.github.com/repos/prefecthq/prefect/git/trees/main?recursive=1"
    )
    headers = {"Authorization": f"Bearer {token}"}
    tree_contents = httpx.get(tree_url, headers=headers).json()["tree"]

    collections = []
    for tree in tree_contents:
        path = tree["path"]
        if path.startswith("docs/collections") and "prefect-" in path:
            url_contents = httpx.get(tree["url"], headers=headers).json()
            path_contents = base64.b64decode(url_contents["content"]).decode()
            author = yaml.safe_load(path_contents)["author"]
            if author == collection_author:
                collection = Path(path).stem.split("/")[-1]
                collections.append(collection)

    return collections


@flow
def merge_dependabot_pull_request(
    github_credentials: GitHubCredentials,
    pull_request_title: str,
    repository_name: str,
    repository_owner: str,
) -> Dict[str, Any]:
    """
    1. Queries ten pull requests (PR) in the repository
    2. For each PR, check if the title matches with the provided title
    3. Automatically approve the PR if there's a matching PR
    4. Leave "@dependabot merge" which will merge the PR if all tests pass
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
    )["nodes"]

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
    collection_author: str = COLLECTION_AUTHOR,
    pull_request_title: str = DEPENDABOT_PULL_REQUEST_TITLE,
) -> Dict:
    """
    Merge multiple dependabot pull requests across multiple repositories.
    """
    github_credentials = GitHubCredentials.load(block_name)
    collection_names = get_collection_names(
        github_credentials=github_credentials, collection_author=collection_author
    )

    collection_pull_request_states = {}
    for collection_name in collection_names:
        flow_name = f"merge_dependabot_pull_request_in_{collection_name}"
        pull_request_state = merge_dependabot_pull_request.with_options(name=flow_name)(
            github_credentials=github_credentials,
            repository_name=collection_name,
            repository_owner=repository_owner,
            pull_request_title=pull_request_title,
            return_state=True,
        )
        collection_pull_request_states[collection_name] = pull_request_state
    return collection_pull_request_states


if __name__ == "__main__":
    merge_dependabot_pull_requests(
        block_name=BLOCK_NAME,
        repository_owner=REPOSITORY_OWNER,
        collection_author=COLLECTION_AUTHOR,
        pull_request_title=DEPENDABOT_PULL_REQUEST_TITLE,
    )
