#!/bin/bash
set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
PORT="${PORT:-8000}"
REPO_URL="https://github.com/aws-samples/bedrock-access-gateway.git"
REPO_DIR="bedrock-access-gateway"
IMAGE_NAME="bedrock-access-gateway"
CONTAINER_NAME="bedrock-proxy"
SSM_PARAM_NAME="/bedrock-access-gateway/api/key"

# Clone the repo if it doesn't exist
if [ ! -d "$REPO_DIR" ]; then
  echo "Cloning repository..."
  git clone "$REPO_URL"
else
  echo "Repository already exists, skipping clone..."
fi

# Build the Docker image
echo "Building Docker image..."
docker build -f "$REPO_DIR/src/Dockerfile_ecs" -t "$IMAGE_NAME" "$REPO_DIR/src"

# Generate random API key
echo "Generating API key..."
API_KEY=$(openssl rand -base64 30)

# Create SSM parameter with the API key
echo "Creating SSM parameter..."
aws ssm put-parameter \
  --name "$SSM_PARAM_NAME" \
  --value "$API_KEY" \
  --type SecureString \
  --overwrite \
  --region "$AWS_REGION"

echo "API key stored in SSM parameter: $SSM_PARAM_NAME"

# Stop and remove existing container if it exists
docker stop "$CONTAINER_NAME" 2>/dev/null || true
docker rm "$CONTAINER_NAME" 2>/dev/null || true

# Run the container
echo "Starting container..."
DOCKER_ARGS=(
  -d --name "$CONTAINER_NAME"
  --restart unless-stopped
  -e AWS_DEFAULT_REGION="$AWS_REGION"
  -e API_KEY_PARAM_NAME="$SSM_PARAM_NAME"
  -p "$PORT":8080
)

if [ -n "$AWS_ACCESS_KEY_ID" ] && [ -n "$AWS_SECRET_ACCESS_KEY" ]; then
  DOCKER_ARGS+=(-e AWS_ACCESS_KEY_ID="$AWS_ACCESS_KEY_ID")
  DOCKER_ARGS+=(-e AWS_SECRET_ACCESS_KEY="$AWS_SECRET_ACCESS_KEY")
else
  DOCKER_ARGS+=(-v ~/.aws:/home/appuser/.aws:ro)
  [ -n "$AWS_PROFILE" ] && DOCKER_ARGS+=(-e AWS_PROFILE="$AWS_PROFILE")
fi

docker run "${DOCKER_ARGS[@]}" "$IMAGE_NAME"

echo "Done! Container is running on http://localhost:$PORT"
echo "API key: $API_KEY (keep this key, you will need it later)"
