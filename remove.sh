#!/bin/bash
set -e

CONTAINER_NAME="bedrock-proxy"

echo "Stopping $CONTAINER_NAME..."
docker stop "$CONTAINER_NAME" 2>/dev/null || true

echo "Removing $CONTAINER_NAME..."
docker rm "$CONTAINER_NAME"
echo "Done!"
