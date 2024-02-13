from typing import Any

from dotenv import dotenv_values
from prefect import flow
from prefect.blocks.system import Secret


def rename_keys(d: dict[str, Any]) -> dict[str, Any]:
    """
    Variable names need to be renamed in order to be valid Block names.

    Examples:
    --------
    >>> original = {'TEST_KEY':"test_value", "test-key-valid":"test_value"}
    >>> rename_keys(original)
    {'test-key': 'test_value', 'test-key-valid': 'test_value'}

    """
    n = {}
    for k, v in d.items():
        n[k.replace("_", "-").casefold()] = v
    return n


@flow(log_prints=True)
def load_secrets(fp: str, overwrite: bool = False):
    original_values = dotenv_values(fp, verbose=True)

    if original_values == {}:
        raise IOError("File not found or empty")

    d = rename_keys(original_values)
    for k, v in d.items():
        secret = Secret(value=v)
        uuid = secret.save(name=k, overwrite=overwrite)
        print(k, uuid)


if __name__ == "__main__":
    env_file = "flows-advanced/dot-env-secrets/sample-dot-env"
    load_secrets(env_file)
