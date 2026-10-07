#!/bin/bash
set -euxo pipefail

# 1. Install and start Docker
dnf install -y docker
systemctl enable --now docker

# 2. Restore the world from S3 if a backup exists
mkdir -p /data
aws s3 sync s3://${bucket}/world/ /data/ --region ${region} || true

# 3. The container runs as uid 1000. Restored files are owned by root,
#    so fix ownership BEFORE starting the server.
chown -R 1000:1000 /data

# 4. Start Minecraft
docker run -d --name mc --restart unless-stopped \
  -p 25565:25565 \
  -e EULA=TRUE \
  -e MEMORY=2G \
  -v /data:/data \
  itzg/minecraft-server