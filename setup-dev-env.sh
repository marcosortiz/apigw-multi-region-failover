#!/bin/bash
#
# Setup script for Lambda local testing environment
# Usage: ./setup-dev-env.sh
#

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Lambda Local Testing Environment Setup${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""

# Check Python version
echo -e "${YELLOW}Checking Python version...${NC}"
PYTHON_VERSION=$(python3 --version 2>&1 | cut -d' ' -f2 | cut -d'.' -f1-2)
REQUIRED_VERSION="3.9"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$PYTHON_VERSION" | sort -V | head -n1)" = "$REQUIRED_VERSION" ]; then
    echo -e "${GREEN}✓ Python $PYTHON_VERSION is compatible${NC}"
else
    echo -e "${RED}✗ Python $PYTHON_VERSION is not compatible (requires Python $REQUIRED_VERSION+)${NC}"
    exit 1
fi

# Check if pip is available
echo -e "${YELLOW}Checking pip...${NC}"
if command -v pip3 >/dev/null 2>&1; then
    echo -e "${GREEN}✓ pip3 is available${NC}"
    PIP_CMD="pip3"
elif command -v pip >/dev/null 2>&1; then
    echo -e "${GREEN}✓ pip is available${NC}"
    PIP_CMD="pip"
else
    echo -e "${RED}✗ pip is not available${NC}"
    echo "Please install pip: https://pip.pypa.io/en/stable/installation/"
    exit 1
fi

# Install Python dependencies
echo -e "${YELLOW}Installing Python dependencies...${NC}"
if [ -f "requirements-dev.txt" ]; then
    $PIP_CMD install -r requirements-dev.txt
    echo -e "${GREEN}✓ Python dependencies installed${NC}"
else
    echo -e "${RED}✗ requirements-dev.txt not found${NC}"
    exit 1
fi

# Check for Docker (optional for SAM CLI)
echo -e "${YELLOW}Checking Docker...${NC}"
if command -v docker >/dev/null 2>&1; then
    if docker ps >/dev/null 2>&1; then
        echo -e "${GREEN}✓ Docker is available and running${NC}"
    else
        echo -e "${YELLOW}⚠ Docker is installed but not running${NC}"
        echo "  Start Docker to enable SAM local testing"
    fi
else
    echo -e "${YELLOW}⚠ Docker is not installed${NC}"
    echo "  Install Docker to enable SAM local testing: https://docs.docker.com/get-docker/"
fi

# Check for SAM CLI (optional)
echo -e "${YELLOW}Checking AWS SAM CLI...${NC}"
if command -v sam >/dev/null 2>&1; then
    SAM_VERSION=$(sam --version 2>&1 | cut -d' ' -f4 || echo "unknown")
    echo -e "${GREEN}✓ AWS SAM CLI $SAM_VERSION is available${NC}"
else
    echo -e "${YELLOW}⚠ AWS SAM CLI is not installed${NC}"
    echo "  Install SAM CLI to enable local Lambda testing:"
    echo "  https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html"
fi

# Make scripts executable
echo -e "${YELLOW}Setting up scripts...${NC}"
chmod +x run-unit-tests.sh
chmod +x run-local-invoke.sh
chmod +x run-local-api.sh
chmod +x run-simple-tests.py
echo -e "${GREEN}✓ Scripts are executable${NC}"

# Run initial validation
echo -e "${YELLOW}Running initial validation...${NC}"
python3 run-simple-tests.py

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Setup Complete!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Your Lambda local testing environment is ready!${NC}"
echo ""
echo -e "${BLUE}Quick start:${NC}"
echo "  # Run unit tests:"
echo "    ./run-unit-tests.sh"
echo ""
echo "  # Test Lambda functions locally (requires Docker + SAM CLI):"
echo "    ./run-local-invoke.sh"
echo ""
echo "  # Start local API (requires Docker + SAM CLI):"
echo "    ./run-local-api.sh service1"
echo ""
echo "  # For more options, see:"
echo "    cat TESTING-QUICKREF.md"
echo ""

# Check if git hooks should be installed
if [ -d ".git" ]; then
    echo -e "${YELLOW}Would you like to install git pre-commit hooks? [y/N]${NC}"
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        cp .git-hooks/pre-commit .git/hooks/pre-commit
        chmod +x .git/hooks/pre-commit
        echo -e "${GREEN}✓ Git pre-commit hooks installed${NC}"
    fi
fi

echo ""
echo -e "${GREEN}Happy testing! 🚀${NC}"