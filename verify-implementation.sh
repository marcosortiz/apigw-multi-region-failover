#!/bin/bash
#
# Comprehensive verification script for Lambda testing infrastructure
#

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}======================================${NC}"
echo -e "${BLUE}Lambda Testing Infrastructure Verification${NC}"
echo -e "${BLUE}======================================${NC}"
echo ""

# 1. Check file structure
echo -e "${BLUE}[1/6] Verifying file structure...${NC}"
for file in \
    "service1/src/app.py" \
    "service2/src/app.py" \
    "external-api/src/app.py" \
    "service1/tests/test_handler.py" \
    "service2/tests/test_handler.py" \
    "external-api/tests/test_handler.py" \
    "service1/events/api-gateway-get.json" \
    "service2/events/api-gateway-get.json" \
    "external-api/events/api-gateway-get.json" \
    "run-simple-tests.py" \
    "run-unit-tests.sh" \
    "run-local-invoke.sh" \
    "run-local-api.sh" \
    "setup-dev-env.sh" \
    "requirements-dev.txt" \
    "pytest.ini" \
    "Makefile" \
    "TESTING.md" \
    "TESTING-QUICKREF.md"; do
    if [ ! -f "$file" ]; then
        echo -e "${RED}✗ Missing: $file${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All required files present${NC}"

# 2. Validate Python syntax
echo -e "${BLUE}[2/6] Validating Python syntax...${NC}"
python3 -m py_compile service1/src/app.py
python3 -m py_compile service2/src/app.py
python3 -m py_compile external-api/src/app.py
python3 -m py_compile run-simple-tests.py
echo -e "${GREEN}✓ All Python files are syntactically correct${NC}"

# 3. Test Lambda functions directly
echo -e "${BLUE}[3/6] Testing Lambda functions...${NC}"
for service in service1 service2 external-api; do
    cd $service/src
    python3 -c "
import app
import json
result = app.lambda_handler({}, {})
assert result['statusCode'] == 200
body = json.loads(result['body'])
assert 'service' in body
assert 'region' in body
print('  ✓ $service works')
" || exit 1
    cd ../..
done
echo -e "${GREEN}✓ All Lambda functions work correctly${NC}"

# 4. Run unit tests
echo -e "${BLUE}[4/6] Running unit tests...${NC}"
python3 run-simple-tests.py > /dev/null 2>&1
if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ All unit tests passed${NC}"
else
    echo -e "${RED}✗ Unit tests failed${NC}"
    exit 1
fi

# 5. Verify SAM templates
echo -e "${BLUE}[5/6] Verifying SAM template updates...${NC}"
for service in service1 service2 external-api; do
    if grep -q "CodeUri: src/" $service/template.yaml && \
       grep -q "Handler: app.lambda_handler" $service/template.yaml; then
        echo -e "  ✓ $service template correctly references external code"
    else
        echo -e "${RED}✗ $service template not updated correctly${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All SAM templates updated correctly${NC}"

# 6. Verify scripts are executable
echo -e "${BLUE}[6/6] Verifying script permissions...${NC}"
for script in run-simple-tests.py run-unit-tests.sh run-local-invoke.sh run-local-api.sh setup-dev-env.sh; do
    if [ -x "$script" ]; then
        echo -e "  ✓ $script is executable"
    else
        echo -e "${RED}✗ $script is not executable${NC}"
        exit 1
    fi
done
echo -e "${GREEN}✓ All scripts have correct permissions${NC}"

echo ""
echo -e "${GREEN}======================================${NC}"
echo -e "${GREEN}✓ All Verifications Passed!${NC}"
echo -e "${GREEN}======================================${NC}"
echo ""
echo -e "${BLUE}Lambda testing infrastructure is ready to use!${NC}"
echo ""
echo -e "Quick start:"
echo -e "  ${GREEN}python3 run-simple-tests.py${NC}     # Run unit tests"
echo -e "  ${GREEN}./run-local-invoke.sh${NC}           # Test with SAM CLI (requires Docker)"
echo -e "  ${GREEN}./run-local-api.sh service1${NC}     # Start local API (requires Docker)"
echo ""
