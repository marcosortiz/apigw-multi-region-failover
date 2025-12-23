#!/bin/bash
#
# Start local API Gateway endpoints for all services
# This script starts SAM local API for testing API Gateway integration locally
# Usage: ./run-local-api.sh [service] [port]
#   service: service1, service2, or external-api (required)
#   port: Port number (default: 3000 for service1, 3001 for service2, 3002 for external-api)
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

SERVICE=${1:-}
PORT=${2:-}

if [ -z "$SERVICE" ]; then
    echo -e "${RED}Error: Service name is required${NC}"
    echo "Usage: ./run-local-api.sh [service] [port]"
    echo "  service: service1, service2, or external-api"
    echo "  port: Port number (optional)"
    exit 1
fi

# Set default port based on service
if [ -z "$PORT" ]; then
    case $SERVICE in
        service1)
            PORT=3000
            ;;
        service2)
            PORT=3001
            ;;
        external-api)
            PORT=3002
            ;;
        *)
            echo -e "${RED}Unknown service: $SERVICE${NC}"
            echo "Valid services: service1, service2, external-api"
            exit 1
            ;;
    esac
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Starting Local API for $SERVICE${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${YELLOW}API will be available at: http://127.0.0.1:$PORT${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop the server${NC}"
echo ""

cd "$SERVICE"

sam local start-api \
    --port "$PORT" \
    --region us-east-1 \
    --warm-containers EAGER

cd ..
