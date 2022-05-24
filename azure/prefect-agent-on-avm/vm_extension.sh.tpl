#!/bin/bash

#Package updates and installation
apt-get update -y

#Install pip3
apt install python3-pip -y

#Install prefect
python3 -m pip install -U "prefect>=2.0b"

#Create a default work-queue
runuser -l ${adminuser} -c '/usr/local/bin/prefect work-queue create default'

cat << EOF > /etc/systemd/system/prefect-agent.service
[Unit]
Description=Prefect Agent Service
After=network.target
StartLimitIntervalSec=0

[Service]
Type=simple
Restart=always
RestartSec=1
User=azureuser
ExecStart=/usr/local/bin/prefect agent start default

[Install]
WantedBy=default.target
EOF

#Reload systemctl to pickup the service
systemctl daemon-reload

#Enable the service to start on boot
systemctl enable prefect-agent

#Start the service
systemctl start prefect-agent