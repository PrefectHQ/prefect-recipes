# Customer Monorepo with S3 Flow Storage on EKS

## Iterating on flows
```sh
git clone https://github.com/customer/monorepo.git
git checkout -b dev/my-new-branch
```



Activate a virtual environment (for example):

```sh
poetry install
poetry shell
```

Test code locally and push changes to GitHub as needed.


## Registering flows

When you're ready to productionalize a flow, running from the directory with your `flow.py`:
```sh
prefect register -p flow.py --project "DEMO"
```
This registration will push your `flow.py` as a script to S3 according to the flow's `Storage` object.

```python
PROJECT = "DEMO"

S3_storage = S3(
    bucket = "prefect-flows",
    key = f"{PROJECT}/flow.py",
    stored_as_script = True,
    local_script_path = "flow.py",
)
```