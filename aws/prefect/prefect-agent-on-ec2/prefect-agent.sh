#!/usr/bin/env bash
yum update -y

# install ssm
cd /tmp 
yum install -y https://s3.${region}.amazonaws.com/amazon-ssm-${region}/latest/${linux_type}/amazon-ssm-agent.rpm
systemctl enable amazon-ssm-agent 
systemctl start amazon-ssm-agent

cd /

# install and start start docker
amazon-linux-extras install docker -y
service docker start

# intall jq
yum install jq -y

# install aws logs
yum install awslogs -y

# update config to ship logs to local region
echo "[plugins]
cwlogs = cwlogs
[default]
region = ${region}" >> /etc/awslogs/awscli.conf

# start the logs service
systemctl start awslogsd
systemctl enable awslogsd.service

# prefect agent install
pip3 install prefect

# get API key
result=$(aws secretsmanager get-secret-value --secret-id ${prefect_secret_id} --region ${region})
secret=$(echo $result | jq -r '.SecretString')
PREFECT_API_KEY=$(echo $secret | jq -r '.${prefect_secret_id}')

# create systemd config
touch /etc/systemd/system/prefect-agent.service
echo "[Unit]
Description=Prefect Docker Agent
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=always
RestartSec=1
User=root
ExecStart=/usr/local/bin/prefect agent docker start -k $PREFECT_API_KEY
[Install]
WantedBy=multi-user.target " >> /etc/systemd/system/prefect-agent.service

# start prefect agent
systemctl start prefect-agent

# install cred helper
amazon-linux-extras enable docker
yum install amazon-ecr-credential-helper -y

mkdir ~/.docker
touch ~/.docker/config.json
echo '{
	"credsStore": "ecr-login"
}' >> ~/.docker/config.json