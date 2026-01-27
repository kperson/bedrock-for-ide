#!/bin/bash
set -e

AWS_REGION="${AWS_REGION:-us-east-1}"
SSM_PARAM_NAME="/bedrock-access-gateway/api/key"

aws ssm get-parameter \
  --name "$SSM_PARAM_NAME" \
  --with-decryption \
  --query Parameter.Value \
  --output text \
  --region "$AWS_REGION"
