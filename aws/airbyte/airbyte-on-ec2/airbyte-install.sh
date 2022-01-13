#!/usr/bin/env bash
yum update -y

# install ssm
yum install -y https://s3.${region}.amazonaws.com/amazon-ssm-${region}/latest/${linux_type}/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent 
systemctl start amazon-ssm-agent

# install and start docker
amazon-linux-extras install docker -y
service docker start

# install docker compose
wget https://github.com/docker/compose/releases/download/1.26.2/docker-compose-$(uname -s)-$(uname -m) -O /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# install and start airbyte
mkdir airbyte && cd airbyte
wget https://raw.githubusercontent.com/airbytehq/airbyte/master/{.env,docker-compose.yaml}
docker-compose up -d

# install aws logs
yum install awslogs -y

# update config to ship logs to local region
echo "[plugins]
cwlogs = cwlogs
[default]
region = ${region}" > /etc/awslogs/awscli.conf

# update log group name
sed -i 's|/var/log/messages|''/airbyte/var/log/messages''|g' /etc/awslogs/awslogs.conf
sed -i 's|file = /airbyte/var/log/messages|''file = /var/log/messages''|g' /etc/awslogs/awslogs.conf

# start the logs service
systemctl start awslogsd
systemctl enable awslogsd.service