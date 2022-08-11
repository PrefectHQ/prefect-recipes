import toml

from prefect import Client

# Get prefect client
client = Client()

CONFIG = "~/.prefect/config.toml"

# all secrets in the config.toml at the CONFIG path
secrets = toml.load(CONFIG)["context"]["secrets"]

# the only secret names you want to sync to your cloud tenant
# replace with your desired list comprehension

allow_list = ["SPECIFIC_SECRET_TO_SYNC"]
allow_list = [s for s in secrets if s.startswith("PREFIX_TO_SYNC_")]

# secret names you don't want to sync to your cloud tenant
# replace with your desired list comprehension

deny_list = ["EXTRA_SECRET_SECRET1", "EXTRA_SECRET_SECRET2"]
deny_list = [s for s in secrets if s.startswith("PREFIX_TO_NOT_SYNC_")]

# sync desired local secrets to the current cloud tenant
for n, v in secrets.items():
    if n in allow_list:  # OR if n not in deny_list:
        print(f"Setting cloud secret: {n}")
        client.set_secret(name=n, value=v)
