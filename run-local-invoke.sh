#!/bin/bash
#
# Test Lambda functions locally using SAM CLI
# This script invokes Lambda functions locally with test events
# Usage: ./run-local-invoke.sh [service]
#   service: service1, service2, or external-api (default: all)
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if SAM CLI is installed
if ! command -v sam &> /dev/null; then
    echo -e "${RED}Error: AWS SAM CLI is not installed${NC}"
    echo "Please install it: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
    exit 1
fi

# Function to invoke Lambda locally
invoke_lambda() {
    local service=$1
    local function_name=$2
    local event_file=$3
    
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}Testing $service${NC}"
    echo -e "${BLUE}========================================${NC}"
    
    cd "$service"
    
    echo -e "${YELLOW}Invoking $function_name with test event...${NC}"
    sam local invoke "$function_name" \
        --event "$event_file" \
        --region us-east-1
    
    if [ $? -eq 0 ]; then
        echo -e "${GREEN}✓ $service Lambda invoked successfully${NC}"
    else
        echo -e "${RED}✗ $service Lambda invocation failed${NC}"
        cd ..
        exit 1
    fi
    
    cd ..
    echo ""
}

# Main execution
SERVICE=${1:-all}

echo -e "${BLUE}=======================================${NC}"
echo -e "${BLUE}AWS Lambda Local Testing with SAM CLI${NC}"
echo -e "${BLUE}=======================================${NC}"
echo ""

if [ "$SERVICE" = "all" ]; then
    invoke_lambda "service1" "Service1LambdaRegionalApi" "events/api-gateway-get.json"
    invoke_lambda "service2" "Service2LambdaRegionalApi" "events/api-gateway-get.json"
    invoke_lambda "external-api" "RootLambdaRegionalApi" "events/api-gateway-get.json"
else
    case $SERVICE in
        service1)
            invoke_lambda "service1" "Service1LambdaRegionalApi" "events/api-gateway-get.json"
            ;;
        service2)
            invoke_lambda "service2" "Service2LambdaRegionalApi" "events/api-gateway-get.json"
            ;;
        external-api)
            invoke_lambda "external-api" "RootLambdaRegionalApi" "events/api-gateway-get.json"
            ;;
        *)
            echo -e "${RED}Unknown service: $SERVICE${NC}"
            echo "Valid services: service1, service2, external-api, all"
            exit 1
            ;;
    esac
fi

echo -e "${GREEN}=======================================${NC}"
echo -e "${GREEN}All Lambda functions tested successfully!${NC}"
echo -e "${GREEN}=======================================${NC}"
