from prefect import Client
import toml

# Get prefect client
client = Client()

CONFIG = '~/.prefect/config.toml'

# all secrets in the config.toml at the CONFIG path
secrets = toml.load(CONFIG)['context']['secrets']

# the only secret names you want to sync to your cloud tenant
whitelist = ['SPECIFIC_SECRET_TO_SYNC']

# secret names you don't want to sync to your cloud tenant
blacklist = ['EXTRA_SECRET_SECRET1', 'EXTRA_SECRET_SECRET2']

# sync desired local secrets to the current cloud tenant
for n, v in secrets.items():
    if n in whitelist: # OR if n not in blacklist: 
        print(f'Setting cloud secret: {n}')
        client.set_secret(name=n, value=v)