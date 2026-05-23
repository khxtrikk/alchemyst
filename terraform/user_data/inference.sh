#!/bin/bash
set -ex

# Update and install dependencies
apt-get update
apt-get install -y git curl python3-pip python3-venv

# Clone the repository
cd /opt
git clone ${repository_url} quickstart
cd quickstart/workers/inference-worker

# Fix the version parsing crash between transformers and gguf
sed -i 's/^gguf.*/gguf==0.9.1/' requirements.txt
sed -i 's/^transformers.*/transformers==4.41.2/' requirements.txt

# Setup Python environment
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt

# Create the inference worker systemd service
cat << 'EOF' > /etc/systemd/system/iii-inference.service
[Unit]
Description=iii Inference Worker (Python)
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/opt/quickstart/workers/inference-worker
Environment="III_URL=ws://${gateway_ip}:49134"
# Run inside the venv
ExecStart=/opt/quickstart/workers/inference-worker/venv/bin/python inference_worker.py
Restart=always
RestartSec=5

[Install]
WantedBy=multi-user.target
EOF

# Enable and start the service
systemctl daemon-reload
systemctl enable iii-inference.service
systemctl start iii-inference.service
