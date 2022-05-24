#!/bin/bash

#Set noninteractive for the front-end
export DEBIAN_FRONTEND=noninteractive
#Package updates and installation
echo "Running apt-get update"
sudo apt-get update -y && sudo apt-get install -y python3-pip &> /tmp/apt_get_update.out

#Install prefect
echo "Running pip install prefect"
python3 -m pip install -U "prefect>=2.0b" &> /tmp/install_prefect.out

#Create a default work-queue
echo "Creating a default work-queue"
runuser -l ${adminuser} -c '/usr/local/bin/prefect work-queue create ${defaultqueue}'

echo "Creating the service config in /etc/systemd/system/prefect-agent.service"
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
ExecStart=/usr/local/bin/prefect agent start ${defaultqueue}

[Install]
WantedBy=default.target
EOF

#Reload systemctl to pickup the service
echo "Reloading systemctl"
systemctl daemon-reload

#Enable the service to start on boot
echo "Enabling the prefect-agent"
systemctl enable prefect-agent

#Start the service
echo "Starting the prefect agent"
systemctl start prefect-agent