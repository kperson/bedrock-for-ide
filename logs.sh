#!/bin/bash

CONTAINER_NAME="bedrock-proxy"

docker logs "$CONTAINER_NAME" "$@"
