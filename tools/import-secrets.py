from prefect import Client
import toml

client = Client()

CONFIG = 'config.toml' # probably this in practice: '~/.prefect/config.toml'

secrets = toml.load(CONFIG)['context']['secrets']

for n, v in secrets.items():
    print(f'Setting secret: {n}')
    client.set_secret(name=n, value=v)