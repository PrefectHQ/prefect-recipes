#!/usr/bin/env bash

# Update PATH for Prefect Install
export PATH="$HOME/.local/bin:$PATH"

# update image & setup docker
apt-get update -y
apt upgrade -y
apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    python3-pip

mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
service docker start
chown $USER /var/run/docker.sock

# prefect agent install
pip3 install prefect

# get API key
PREFECT_API_KEY=${prefect_api_key}

# create prefect config file
# mkdir ~/.prefect
# touch ~/.prefect/config.toml
# echo "
# [cloud.agent]
# " > ~/.prefect/config.toml

# create systemd config
touch /etc/systemd/system/prefect-agent.service
echo "[Unit]
Description=Prefect Agent
After=network.target
StartLimitIntervalSec=0
[Service]
Type=simple
Restart=on-failure
RestartSec=5
User=root
ExecStart=/usr/local/bin/prefect agent start -q ${work_queue} --api ${prefect_api_address}
[Install]
WantedBy=multi-user.target " >> /etc/systemd/system/prefect-agent.service

# start prefect agent
systemctl start prefect-agent
systemctl daemon-reload
