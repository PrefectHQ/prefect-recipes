import boto3
import logging
import os

# setup logger
log = logging.getLogger()
log.setLevel(logging.INFO)


def lambda_handler(event, context):
    # grab new instance id
    instance_id = event["detail"]["EC2InstanceId"]
    ebs_id = os.environ["EBS_VOLUME_ID"]

    # establish Connection
    ec2 = boto3.client("ec2")

    try:
        response = ec2.attach_volume(
            Device="/dev/sdh",
            InstanceId=instance_id,
            VolumeId=ebs_id,
        )
        log.info(f"succesfully attached volume {ebs_id} to instance {instance_id}")

    except Exception as e:
        log.error(e)