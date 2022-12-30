"""
If you want to integrate Prefect with an external service that runs jobs,
you're in the right place!

The `JobBlock` is a subclass of `Block` that helps cleanly represent a job that
can be executed within an external service, which can then be registered to and 
managed from your Prefect workspace UI.

The actual `JobBlock` class has a single abstract method that must be implemented:
    `trigger`: a method that triggers the job and returns a `JobRun` object

The `JobRun` class (which is not a Block) contains stateful information related to
a specific run of a `JobBlock` and has 2 abstract methods that must be implemented:
    - `wait_for_completion`: a method that blocks until the job is complete
    - `fetch_result`: a method that fetches the result of the job


Let's write a `FooJob` block that represents a job running in an external service Foo,
and and a `FooJobRun` class that represents a specific run of a `FooJob` block.


(Reminder that `Block` inherits from `pydantic.BaseModel` and therefore
has all the same features like support for `Field` objects, validators, etc.)

Let's do this!
"""

# because we'll be doing async stuff
import asyncio

# let's import the base classes we'll be extending
from prefect.blocks.abstract import CredentialsBlock, JobBlock, JobRun

# if Foo has a Python client, import it here
from prefect.client.base import PrefectHttpxClient

# let's import a little wizardry to allow our block methods
# to be run in either sync or async contexts
from prefect.utilities.asyncutils import sync_compatible

# really nice for type hinting and rendering fields in the UI
from pydantic import Field


# while not explicitly required, it's typically nice to have a
# `CredentialsBlock` that's able to generate clients for your service
# so let's write one for Foo
class FooCredentials(CredentialsBlock):
    """Handle auth setup and any necessary validators here."""

    api_key: str = Field(...)

    base_url: str = Field(
        default="https://foo.com/api/v1",
    )

    def get_client(self):
        """If Foo has a Python client, return it here.
        Bonus points if it works as a context manager!
        """
        headers = {"Authorization": f"Bearer {self.api_key}"}

        return PrefectHttpxClient(headers=headers)


# now let's write a `FooJobRun` class that represents a specific run of a `FooJob`
class FooJobRun(JobRun):
    """A specific run of a `FooJob` block."""

    def __init__(self, foo_job, job_id):
        self.foo_job = foo_job
        self.job_id = job_id
        self._terminal_states = {"complete", "failed", "cancelled"}

    @sync_compatible
    async def wait_for_completion(self):
        """Blocks until the job is complete."""

        async with self.foo_job.credentials.get_client() as client:
            # poll the job status until it's complete
            while status not in self._terminal_states:
                status = await client.get(
                    f"{self.foo_job.credentials.base_url}/jobs/{self.job_id}"
                )

                if status == "complete":
                    # `JobRun` has a `logger` attribute that you can use
                    self.logger.info(f"Job {self.job_id} completed!")
                    break

                await asyncio.sleep(self.foo_job.poll_interval_s)

    @sync_compatible
    async def fetch_result(self):
        """Fetches the result of the job.

        Instead of another API call, it may sometimes be more appropriate to
        collect certain information stored on the `JobRun` object itself.
        """

        async with self.foo_job.credentials.get_client() as client:
            # fetch the result of the job
            result = await client.get(
                f"{self.foo_job.credentials.base_url}/jobs/{self.job_id}/result"
            )

            return result


class FooJob(JobBlock):
    """A job that runs in Foo."""

    credentials: FooCredentials = Field(
        default=...,
        description="The credentials block to create clients for Foo.",
    )

    poll_interval_s: int = Field(
        default=5,
        description="The number of seconds to wait between polling the job status.",
    )

    @sync_compatible
    async def trigger(self):
        """
        Triggers the job in Foo and returns a `FooJobRun` object.
        """

        async with self.credentials.get_client() as client:
            # trigger the job in Foo
            job_id = await client.post(f"{self.credentials.base_url}/jobs")

            # return a `FooJobRun` object and store the `FooJob` block on it
            # so we can easily grab a client and poll interval when we need them
            return FooJobRun(
                foo_job=self,
                job_id=job_id,
            )


"""
We're done! Now we can use our `FooJob` block to quickly and easily
construct flows that run jobs in Foo - let's see some quick examples.
"""

from prefect import flow, task


@flow(name="Foo Job Flow")  # or `@task` if you want
async def run_foo_job_without_tasks(foo_job: FooJob):
    job_run = await foo_job.trigger()
    await job_run.wait_for_completion()
    return await job_run.fetch_result()


# let's do another one that calls our block methods as tasks


@flow(name="Foo Job Flow with Tasks")
async def run_foo_job(foo_job: FooJob):
    """One slightly obscure thing to note here is that we're passing
    the underlying async `FooJob` methods into our `task` decorator here
    to treat them as async, since a flow provides an existing event loop.

    Note the `aio` retrieval on the method names and the fact that we're
    passing the object to which the method belongs to the task call.
    """

    job_run = await task(foo_job.trigger.aio)(foo_job)

    await task(job_run.wait_for_completion.aio)(job_run)

    return await task(job_run.fetch_result.aio)(job_run)


# and now we can run our flows - since Foo is definitely a real service!
