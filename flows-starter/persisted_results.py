"""This example demonstrates how to use a custom result storage and serializer.

You can retrieve a result from a custom storage by passing the storage block ID
that was used to store the result, the serializer type, and the storage key to
`prefect.results.PersistedResult` and calling its `get` method.
"""

from prefect import flow, task
from prefect.filesystems import GCS
from prefect.results import PersistedResult

STORAGE = GCS.load("marvin-result-storage")
SERIALIZER = "json"
STORAGE_KEY = "foo.json"


@task(result_storage_key=STORAGE_KEY)
def add(x, y):
    return x + y


@flow(
    result_storage=STORAGE,
    result_serializer=SERIALIZER,
)
def my_flow():
    return add(1, 2)


if __name__ == "__main__":
    local_result = my_flow()

    result_ref = PersistedResult(
        storage_block_id=STORAGE._block_document_id,
        serializer_type=SERIALIZER,
        storage_key=STORAGE_KEY,
    )

    assert local_result == result_ref.get() == 3
