#!/bin/bash
#
# Run unit tests for all Lambda functions
# Usage: ./run-unit-tests.sh [options]
#   -v, --verbose    Enable verbose output
#   -c, --coverage   Generate coverage report
#   -s, --service    Test specific service (service1, service2, external-api)
#

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Default options
VERBOSE=""
COVERAGE=""
SERVICE=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE="-v"
            shift
            ;;
        -c|--coverage)
            COVERAGE="--cov=src --cov-report=term --cov-report=html"
            shift
            ;;
        -s|--service)
            SERVICE="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Running Lambda Unit Tests${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Function to run tests for a service
run_service_tests() {
    local service=$1
    echo -e "${GREEN}Testing $service...${NC}"
    cd "$service"
    
    if [ -d "tests" ]; then
        python -m pytest tests/ $VERBOSE $COVERAGE
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ $service tests passed${NC}"
        else
            echo -e "${RED}✗ $service tests failed${NC}"
            exit 1
        fi
    else
        echo -e "${RED}No tests directory found for $service${NC}"
    fi
    
    cd ..
    echo ""
}

# Main execution
if [ -n "$SERVICE" ]; then
    # Test specific service
    run_service_tests "$SERVICE"
else
    # Test all services
    run_service_tests "service1"
    run_service_tests "service2"
    run_service_tests "external-api"
fi

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}All unit tests completed successfully!${NC}"
echo -e "${GREEN}========================================${NC}"

if [ -n "$COVERAGE" ]; then
    echo ""
    echo -e "${BLUE}Coverage reports generated in htmlcov/ directories${NC}"
fi
