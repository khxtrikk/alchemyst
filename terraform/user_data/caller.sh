#!/bin/bash
set -ex

# Update and install dependencies
apt-get update
apt-get install -y git curl nodejs npm

# Clone the repository
cd /opt
git clone ${repository_url} quickstart
cd quickstart/workers/caller-worker

# Install Node dependencies
npm install
npm install -g tsx

# Create the caller worker systemd service
cat << 'EOF' > /etc/systemd/system/iii-caller.service
[Unit]
Description=iii Caller Worker (TypeScript)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/quickstart/workers/caller-worker
Environment="III_URL=ws://${gateway_ip}:49134"
ExecStart=/usr/local/bin/tsx src/worker.ts
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable iii-caller.service
systemctl start iii-caller.service
