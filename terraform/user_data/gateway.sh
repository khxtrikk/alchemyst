#!/bin/bash
set -ex

# Update and install dependencies
apt-get update
apt-get install -y git curl nodejs npm jq unzip

# Install iii engine
curl -fsSL https://install.iii.dev/iii/main/install.sh | BIN_DIR=/usr/local/bin sh

# Clone the repository
cd /opt
git clone ${repository_url} quickstart
cd quickstart

# Create the gateway systemd service
cat << 'EOF' > /etc/systemd/system/iii-gateway.service
[Unit]
Description=iii API Gateway
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/quickstart
# Ensure config.yaml is updated to bind to 0.0.0.0 and no worker_paths
ExecStart=/usr/local/bin/iii --config config.yaml
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Ensure the config binds to 0.0.0.0 (fallback if not already set in the repo)
sed -i 's/host: 127.0.0.1/host: 0.0.0.0/g' /opt/quickstart/config.yaml

# Enable and start the service
systemctl daemon-reload
systemctl enable iii-gateway.service
systemctl start iii-gateway.service
