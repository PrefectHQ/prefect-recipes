from prefect import Client
import toml

client = Client()

CONFIG = 'config.toml' # probably this in practice: '~/.prefect/config.toml'

secrets = toml.load(CONFIG)['context']['secrets']

blacklist = ['EXTRA_SECRET_SECRET1', 'EXTRA_SECRET_SECRET2']

for n, v in secrets.items():
    if n not in blacklist:
        print(f'Setting secret: {n}')
        client.set_secret(name=n, value=v)