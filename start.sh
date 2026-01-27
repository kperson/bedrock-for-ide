#!/bin/bash
set -e

CONTAINER_NAME="bedrock-proxy"

echo "Starting $CONTAINER_NAME..."
docker start "$CONTAINER_NAME"
echo "Done!"
