from types import ModuleType
from typing import Union

import click
import pdoc

from prefect import Client
from prefect.utilities.graphql import with_args


def docfilter(docobject):
    print(docobject)


@click.command()
@click.option(
    "--project",
    "-p",
    help="The name of the Prefect project to register this flow in. Required.",
    required=True,
)
@click.option(
    "--module",
    "-m",
    help="A python module name containing the flow to register. Required.",
    required=True,
)
def register_flow(project: str, module: Union[ModuleType, str], **kwargs):
    pdoc3_module = pdoc.Module(module=module)
    flow = pdoc3_module.obj.flow
    flow_id = flow.register(project_name=project, **kwargs)
    client = Client()
    flow_group_id = client.graphql(
        {
            "query": {
                with_args(
                    "flow",
                    {
                        "where": {
                            "id": {
                                "_eq": flow_id,
                            },
                        },
                    },
                ): {"flow_group_id"}
            }
        }
    )["data"]["flow"][0]["flow_group_id"]
    docfilter = lambda doc: doc.name in [t.name for t in flow.tasks]
    pdoc3_module = pdoc.Module(module=module, docfilter=docfilter)
    module_markdown = pdoc3_module.text()
    # Do some post-processing to keep Prefect engine from misinterpreting
    # the markdown.
    module_markdown = (
        module_markdown.replace(":   ", ":\n")
        .replace("\n:", ":")
        .replace("\n    ", "\n")
    )
    ret = client.graphql(
        {
            "mutation": {
                with_args(
                    "set_flow_group_description",
                    {
                        "input": {
                            "flow_group_id": flow_group_id,
                            "description": module_markdown,
                        },
                    },
                ): {"success"}
            }
        }
    )
    if not ret["data"]["set_flow_group_description"]["success"]:
        raise RuntimeError("Failed to set flow group README")


if __name__ == "__main__":
    register_flow()
