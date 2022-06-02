import json
from typing import List

from prefect.client import Client, Secret


def get_secret_names(client: Client) -> List[str]:
    
    response = client.graphql(query="query {secretNames}")
    
    names = response['data']['secretNames']
    
    return names


def export_current_tenant_secrets() -> None:
    secrets = {i: Secret(i).get() for i in get_secret_names(Client())}
    with open('secrets.json', 'w') as f:
        f.write(json.dumps(secrets))

if __name__ == "__main__":
    export_current_tenant_secrets()
