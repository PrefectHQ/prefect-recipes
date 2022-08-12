"""
Discourse:
https://discourse.prefect.io/t/how-can-i-interact-with-the-backend-api-using-a-python-client/80
"""

from prefect.client import get_client
import asyncio


async def get():

    async with get_client() as client:
        response = await client.hello()
        print(response.json())


asyncio.run(get())
