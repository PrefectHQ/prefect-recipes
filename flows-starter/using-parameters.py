"""
Discourse:
https://discourse.prefect.io/t/guide-to-implementing-parameters-between-prefect-1-0-and-2-0/1321
"""


from prefect import task, flow


@task
def print_plus_one(obj):
    print(f"Received a {type(obj)} with value {obj}")  # Shows the type of the parameter after coercion
    print(obj + 1)  # Adds one


# Note that we define the flow with type hints
@flow
def validation_flow(x: int, y: int):
    print_plus_one(x)
    print_plus_one(y)


validation_flow(x="42", y=100)

# The above prints the following:
# Received a <class 'int'> with value 42
# 43
# Received a <class 'int'> with value 100
# 101
