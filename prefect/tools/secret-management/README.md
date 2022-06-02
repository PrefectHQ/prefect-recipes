# Secret Management scripts
### Note
These scripts use [`prefect.client.Client`](https://docs.prefect.io/api/latest/client/client.html#client-2), which will interact with **your currently active tenant's secrets** by default.

If you have access to multiple tenants, you can verify that you are logged into the desired tenant with: 
```shell
$ prefect auth list-tenants

NAME          SLUG                     ID
IamNotreal    not-a-real-tenant        af696b1e-5137-402e-a9d5-34c53cad54e3
nate          nate-prefect-account     512efbf7-f492-4183-ad32-53a4054ce7bc  *
```

and checking that you have an asterisk next to the tenant you're looking to sync secrets to / from.

## Importing your Prefect (1.0) secrets from your local
In most cases, if you've defined any local secrets, then they live as toml key-value pairs in `~/.prefect/config.toml`. While this can be useful, storing secrets in Prefect Cloud instead will enable other users / service accounts in your tenant to securely use these secrets per RBAC permissions.

### Usage
To move your local secrets to your active cloud tenant, run your script when you're finished customizing your allow / deny list(s)!

```shell
$ python import-secrets.py
```

## Exporting your Prefect (1.0) secrets from your cloud tenant
This script will extract all secrets defined in your active tenant into a JSON file.

### Usage

```shell
$ python export-secrets.py
```