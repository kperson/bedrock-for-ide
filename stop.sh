#!/bin/bash
set -e

CONTAINER_NAME="bedrock-proxy"

echo "Stopping $CONTAINER_NAME..."
docker stop "$CONTAINER_NAME"
echo "Done!"
