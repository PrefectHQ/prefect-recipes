## Importing your Prefect secrets from your local
In most cases, if you've defined any local secrets, then they live as toml key-value pairs in `~/.prefect/config.toml`. While this can be useful, storing secrets in Prefect Cloud instead will enable other users / service accounts in your tenant to securely use these secrets per RBAC permissions.

This short script using [the Prefect Client](https://docs.prefect.io/api/latest/client/client.html#client-2) is meant to provide a starting place for you to read your secrets into *your currently active Prefect Cloud tenant*.

You can verify that you are logged into your tenant by running this: 
```shell
$ prefect auth list-tenants

NAME          SLUG                     ID
IamNotreal    not-a-real-tenant        af696b1e-5137-402e-a9d5-34c53cad54e3
nate          nate-prefect-account     512efbf7-f492-4183-ad32-53a4054ce7bc  *
```

and checking that you have an asterisk next to the tenant you're looking to sync secrets to.

## Usage
For Python users, usage is straight-forward - just run your script when you're finished customizing your allow / deny list(s)!

```shell
$ python import-secrets.py
```
