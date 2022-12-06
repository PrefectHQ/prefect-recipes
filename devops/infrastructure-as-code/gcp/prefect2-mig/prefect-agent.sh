#!/usr/bin/env bash

# update image & setup docker
sudo apt-get update -y
sudo apt upgrade -y 
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-compose-plugin
service docker start

# prefect agent install
pip3 install prefect

# create prefect config file
mkdir ~/.prefect
touch ~/.prefect/config.toml
echo "
[cloud.agent]
labels = ${prefect_labels}
" > ~/.prefect/config.toml

# create systemd config
touch /etc/systemd/system/prefect-agent.service
echo "[Unit]
Description=Prefect Docker Agent
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=on-failure
RestartSec=5
User=root
ExecStart=/usr/local/bin/prefect agent docker start -k $PREFECT_API_KEY --api ${prefect_api_address} ${image_pulling} ${flow_logs} ${config_id}
[Install]
WantedBy=multi-user.target " >> /etc/systemd/system/prefect-agent.service

# start prefect agent
systemctl start prefect-agent
