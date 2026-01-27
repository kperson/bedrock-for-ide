#!/bin/bash
set -e

CONTAINER_NAME="bedrock-proxy"

echo "Restarting $CONTAINER_NAME..."
docker restart "$CONTAINER_NAME"
echo "Done!"
