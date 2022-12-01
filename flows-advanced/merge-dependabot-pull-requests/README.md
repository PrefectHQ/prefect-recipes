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
`pip install prefect prefect-github` and an existing `GitHubCredentials` block created in a Prefect workspace
