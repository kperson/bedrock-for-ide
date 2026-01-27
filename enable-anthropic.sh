#!/bin/bash
set -e

AWS_REGION="${AWS_REGION:-us-east-1}"

echo "=== Enable Anthropic Models on AWS Bedrock ==="
echo ""
echo "This script submits the required use-case form for Anthropic models."
echo "You only need to do this once per AWS account (or once per Organization)."
echo ""

# Prompt for form fields
read -p "Company Name: " COMPANY_NAME
read -p "Company Website: " COMPANY_WEBSITE

echo ""
echo "Intended users:"
echo "  0) Internal employees"
echo "  1) External end users"
read -p "Select intended users (0-1): " INTENDED_USERS_CHOICE

case $INTENDED_USERS_CHOICE in
  0) INTENDED_USERS="0" ;;
  1) INTENDED_USERS="1" ;;
  *)
    echo "Invalid selection, defaulting to internal employees"
    INTENDED_USERS="0"
    ;;
esac

echo ""
echo "Industry options:"
echo "  1) Technology"
echo "  2) Finance"
echo "  3) Healthcare"
echo "  4) Retail"
echo "  5) Education"
echo "  6) Other"
read -p "Select industry (1-6): " INDUSTRY_CHOICE

OTHER_INDUSTRY=""
case $INDUSTRY_CHOICE in
  1) INDUSTRY="Technology" ;;
  2) INDUSTRY="Finance" ;;
  3) INDUSTRY="Healthcare" ;;
  4) INDUSTRY="Retail" ;;
  5) INDUSTRY="Education" ;;
  6)
    INDUSTRY="Other"
    read -p "Specify your industry: " OTHER_INDUSTRY
    ;;
  *)
    echo "Invalid selection, defaulting to Technology"
    INDUSTRY="Technology"
    ;;
esac

echo ""
read -p "Describe your use cases: " USE_CASES

# Build the form data JSON (always include otherIndustryOption)
FORM_DATA=$(cat <<EOF
{
  "companyName": "$COMPANY_NAME",
  "companyWebsite": "$COMPANY_WEBSITE",
  "intendedUsers": "$INTENDED_USERS",
  "industryOption": "$INDUSTRY",
  "otherIndustryOption": "$OTHER_INDUSTRY",
  "useCases": "$USE_CASES"
}
EOF
)

echo ""
echo "Submitting use-case form to AWS Bedrock..."

# Base64 encode the form data as required by the API (remove line breaks)
FORM_DATA_B64=$(echo -n "$FORM_DATA" | base64 | tr -d '\n')

aws bedrock put-use-case-for-model-access \
  --region "$AWS_REGION" \
  --form-data "$FORM_DATA_B64"

echo ""
echo "Done! Anthropic models should now be available in your account."
echo "You can enable specific models in the AWS Bedrock console or via API."
