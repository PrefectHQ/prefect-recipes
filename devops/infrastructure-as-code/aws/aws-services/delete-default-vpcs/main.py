import logging

import boto3

# Setup logger
log = logging.getLogger()
log.setLevel(logging.INFO)


class DefaultVpcDeleter(object):
    def __init__(self, region):
        # Establish session
        session = boto3.session.Session(region_name=region)
        self.ec2 = session.client("ec2")

        # Other variables
        self.region = region
        self.vpcId = ""
        self.dhcpOptionsId = ""
        self.dryRun = False

    def delete(self):
        # Get all VPCs in a region, if none, or an error return to loop
        if not self.get_vpcs():
            return

        # Detach & Delete IGW
        self.delete_igw()

        # Delete Subnets
        self.delete_subnets()

        # Delete VPC
        self.delete_vpc()

        # Delete DHCP Option Set
        self.delete_dhcp()

        log.info(f"VPC {self.vpcId} has been deleted from the {self.region} region.")

    def get_vpcs(self):
        # Get all VPCs
        try:
            vpcs = self.ec2.describe_vpcs()["Vpcs"]

        # Handle exceptions
        except Exception as e:
            log.error(f"Ran into issue describing VPCs in {self.region}: {e}")
            return False

        # If there are none, return
        if not vpcs:
            return False

        # Loop through VPCs and find the default, if it exists
        for vpc in vpcs:
            if vpc["IsDefault"]:
                self.vpcId = vpc["VpcId"]
                self.dhcpOptionsId = vpc["DhcpOptionsId"]
                return True
        # Return false if no default VPC identified
        return False

    def delete_igw(self):
        # Get IGW attached to default VPC
        try:
            igwId = self.ec2.describe_internet_gateways(
                Filters=[{"Name": "attachment.vpc-id", "Values": [self.vpcId]}]
            )["InternetGateways"][0]["InternetGatewayId"]

        # Handle exceptions
        except Exception as e:
            log.error(f"Ran into issue describing IGW in {self.region}: {e}")
            return

        # Detach IGW
        try:
            self.ec2.detach_internet_gateway(
                InternetGatewayId=igwId, VpcId=self.vpcId, DryRun=self.dryRun
            )

        # Handle exceptions
        except Exception as e:
            log.error(f"Ran into issue detaching IGW {igwId}: {e}")
            return

        # Delete IGW
        try:
            self.ec2.delete_internet_gateway(
                InternetGatewayId=igwId, DryRun=self.dryRun
            )

        # Handle exceptions
        except Exception as e:
            log.error(f"Ran into issue deleting IGW {igwId}: {e}")
            return

    def delete_subnets(self):
        # Get Subnets in default VPC
        try:
            subnets = self.ec2.describe_subnets(
                Filters=[
                    {"Name": "vpc-id", "Values": [self.vpcId]},
                ]
            )["Subnets"]

        # Handle exceptions
        except Exception as e:
            log.error(f"Ran into issue describing subnets in {self.region}: {e}")
            return

        # If there are none, return
        if not subnets:
            return

        # Delete subnets
        for subnet in subnets:
            subnetId = subnet["SubnetId"]
            try:
                self.ec2.delete_subnet(SubnetId=subnetId, DryRun=self.dryRun)

            # Handle exceptions
            except Exception as e:
                log.error(f"Ran into issue deleting subnet {subnetId}: {e}")
                return

    def delete_vpc(self):
        # Delete VPC
        try:
            self.ec2.delete_vpc(VpcId=self.vpcId, DryRun=self.dryRun)

        # Handle exceptions
        except Exception as e:
            log.error(f"Ran into issue deleting vpc {self.vpcId}: {e}")
            return

    def delete_dhcp(self):
        # Get DHCP Option Set attached to default VPC
        try:
            self.ec2.delete_dhcp_options(
                DhcpOptionsId=self.dhcpOptionsId, DryRun=self.dryRun
            )

        # Handle exceptions
        except Exception as e:
            log.error(
                f"Ran into issue deleting DHCP Option Sets {self.dhcpOptionsId}: {e}"
            )
            return

    def confirm(self):
        # Get all VPCs
        try:
            vpcs = self.ec2.describe_vpcs()["Vpcs"]

        # Handle exceptions
        except Exception as e:
            log.error(f"Ran into issue describing VPCs in {self.region}: {e}")
            return False

        if not vpcs:
            log.info(f"No default VPC left in {self.region}")
        else:
            log.info(f"The following VPCs remain in {self.region}: {vpcs}")


def lambda_handler(event, context):
    # Establish Connection
    ec2 = boto3.client("ec2")

    # Get all availble regions
    regions = [region["RegionName"] for region in ec2.describe_regions()["Regions"]]

    # Loop through all regions, deleting default VPCs, Subnets, and IGWs
    for region in regions:
        # Create Class
        deleter = DefaultVpcDeleter(region)

        # Delete all default VPC resources
        deleter.delete()

        # Confirm all default VPCs are gone
        deleter.confirm()
