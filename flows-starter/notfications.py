"""
Discourse:
https://discourse.prefect.io/t/sending-notifications-in-cloud-1-0-using-automations-cloud-2-0-slack-webhook-blocks-and-notifications/1315

You will need to create a block in the UI called 'slacknotificationblocktest'
to run this example
"""

from prefect import flow, task
from prefect.blocks.notifications import SlackWebhook  # import the SlackWebhook module


@task(name="SlackNotif")
def test_notif():
    slack_webhook_block = SlackWebhook.load("slacknotificationblocktest")  # load the Slack Webhook block
    slack_webhook_block.notify("Hello from Prefect!")  # create our notification


@flow(name="Important-2.0-Flow")
def basic_flow():
    test_notif()


basic_flow()
