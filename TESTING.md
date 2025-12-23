# Local Lambda Testing Guide

This guide provides comprehensive instructions for testing Lambda functions locally before deploying to AWS, following AWS best practices.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Setup](#setup)
3. [Testing Approaches](#testing-approaches)
4. [Running Unit Tests](#running-unit-tests)
5. [Local Lambda Invocation](#local-lambda-invocation)
6. [Local API Gateway Testing](#local-api-gateway-testing)
7. [Best Practices](#best-practices)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have the following installed:

- **Python 3.9+**: Required for running Lambda functions and tests
- **AWS SAM CLI**: For local Lambda simulation
  - Installation: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html
  - Verify: `sam --version`
- **Docker**: Required by SAM CLI for local Lambda runtime simulation
  - Installation: https://docs.docker.com/get-docker/
  - Verify: `docker --version`
- **pytest**: Python testing framework (installed via requirements-dev.txt)

## Setup

### 1. Install Development Dependencies

```bash
# Install Python testing dependencies
pip install -r requirements-dev.txt
```

This installs:
- `pytest` - Testing framework
- `pytest-cov` - Coverage reporting
- `pytest-mock` - Mocking utilities
- `moto` - AWS service mocking library
- `boto3` - AWS SDK for Python
- `aws-sam-cli` - SAM command line interface

### 2. Verify SAM CLI Installation

```bash
sam --version
```

### 3. Verify Docker is Running

```bash
docker ps
```

## Testing Approaches

This project implements a multi-layered testing strategy:

### 1. **Unit Tests** (Fast, No Dependencies)
- Test Lambda handler functions directly
- No AWS services required
- Use pytest for test execution
- Mock environment variables and dependencies
- **Recommended for:** Development, CI/CD pipelines

### 2. **Local Lambda Invocation** (Simulated Runtime)
- Test Lambda functions in containerized environment
- Simulates actual AWS Lambda runtime
- Uses SAM CLI and Docker
- **Recommended for:** Integration testing, debugging

### 3. **Local API Gateway** (End-to-End Local)
- Test complete API Gateway + Lambda integration
- Start local API endpoints
- Test with curl or browser
- **Recommended for:** API contract testing, manual testing

## Running Unit Tests

Unit tests provide fast feedback without requiring AWS resources or Docker.

### Run All Tests

```bash
./run-unit-tests.sh
```

### Run Tests with Verbose Output

```bash
./run-unit-tests.sh -v
```

### Run Tests with Coverage Report

```bash
./run-unit-tests.sh -c
```

This generates:
- Terminal coverage summary
- HTML coverage report in `htmlcov/` directory

### Run Tests for Specific Service

```bash
./run-unit-tests.sh -s service1
./run-unit-tests.sh -s service2
./run-unit-tests.sh -s external-api
```

### Run Tests Manually

```bash
# Service1
cd service1
python -m pytest tests/ -v

# Service2
cd service2
python -m pytest tests/ -v

# External API
cd external-api
python -m pytest tests/ -v
```

## Local Lambda Invocation

Test Lambda functions in a containerized environment that simulates AWS Lambda runtime.

### Invoke All Lambda Functions

```bash
./run-local-invoke.sh
```

### Invoke Specific Lambda Function

```bash
./run-local-invoke.sh service1
./run-local-invoke.sh service2
./run-local-invoke.sh external-api
```

### Manual Invocation

```bash
# Service1
cd service1
sam local invoke Service1LambdaRegionalApi \
    --event events/api-gateway-get.json \
    --region us-east-1

# Service2
cd service2
sam local invoke Service2LambdaRegionalApi \
    --event events/api-gateway-get.json \
    --region us-east-1

# External API
cd external-api
sam local invoke RootLambdaRegionalApi \
    --event events/api-gateway-get.json \
    --region us-east-1
```

### Custom Test Events

You can create custom test events by adding JSON files to the `events/` directory:

```bash
# Example: Create custom event
cat > service1/events/custom-event.json << 'EOF'
{
  "httpMethod": "GET",
  "path": "/test",
  "headers": {
    "Content-Type": "application/json"
  },
  "body": null
}
EOF

# Invoke with custom event
cd service1
sam local invoke Service1LambdaRegionalApi --event events/custom-event.json
```

## Local API Gateway Testing

Start a local API Gateway endpoint for interactive testing.

### Start Local API for Service1

```bash
./run-local-api.sh service1
# API available at: http://127.0.0.1:3000
```

### Start Local API for Service2

```bash
./run-local-api.sh service2
# API available at: http://127.0.0.1:3001
```

### Start Local API for External API

```bash
./run-local-api.sh external-api
# API available at: http://127.0.0.1:3002
```

### Start with Custom Port

```bash
./run-local-api.sh service1 8080
# API available at: http://127.0.0.1:8080
```

### Test Local API Endpoints

```bash
# Service1
curl http://127.0.0.1:3000/

# Service2
curl http://127.0.0.1:3001/

# External API
curl http://127.0.0.1:3002/
```

Expected response:
```json
{
  "service": "service1",
  "region": "us-east-1"
}
```

## Best Practices

### 1. Test-Driven Development (TDD)

Write unit tests before implementing Lambda logic:

```python
# tests/test_new_feature.py
def test_new_feature():
    result = my_new_function()
    assert result == expected_value
```

### 2. Use Environment Variables

Configure Lambda behavior through environment variables:

```bash
# In SAM template
Environment:
  Variables:
    TABLE_NAME: my-table
    API_KEY: test-key

# In unit tests
import os
os.environ['TABLE_NAME'] = 'test-table'
```

### 3. Mock AWS Services

Use `moto` to mock AWS services in unit tests:

```python
from moto import mock_dynamodb
import boto3

@mock_dynamodb
def test_dynamodb_interaction():
    # Create mock DynamoDB table
    dynamodb = boto3.resource('dynamodb', region_name='us-east-1')
    table = dynamodb.create_table(
        TableName='test-table',
        KeySchema=[{'AttributeName': 'id', 'KeyType': 'HASH'}],
        AttributeDefinitions=[{'AttributeName': 'id', 'AttributeType': 'S'}]
    )
    
    # Test your Lambda function
    result = lambda_handler(event, context)
    assert result['statusCode'] == 200
```

### 4. Test Multiple Scenarios

Create comprehensive test coverage:

```python
def test_success_case():
    """Test successful execution"""
    pass

def test_missing_parameters():
    """Test error handling for missing parameters"""
    pass

def test_invalid_input():
    """Test validation of invalid input"""
    pass

def test_aws_service_failure():
    """Test behavior when AWS service fails"""
    pass
```

### 5. Use Warm Containers

For faster local testing, use warm containers:

```bash
sam local start-api --warm-containers EAGER
```

### 6. Cache Dependencies

Build Lambda dependencies once and reuse:

```bash
# Build all functions
sam build

# Then invoke multiple times without rebuilding
sam local invoke MyFunction --no-build
```

## Troubleshooting

### Issue: SAM CLI Not Found

**Solution:**
```bash
# Install SAM CLI
pip install aws-sam-cli
# Or follow: https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/install-sam-cli.html
```

### Issue: Docker Not Running

**Error:** `Cannot connect to the Docker daemon`

**Solution:**
```bash
# Start Docker Desktop (Mac/Windows)
# Or start Docker daemon (Linux)
sudo systemctl start docker
```

### Issue: Port Already in Use

**Error:** `Address already in use`

**Solution:**
```bash
# Find process using the port
lsof -i :3000

# Kill the process
kill -9 <PID>

# Or use a different port
./run-local-api.sh service1 3003
```

### Issue: Lambda Times Out

**Solution:**
```bash
# Increase timeout in template.yaml
Timeout: 30  # seconds

# Or when invoking
sam local invoke --timeout 60
```

### Issue: Import Errors in Tests

**Error:** `ModuleNotFoundError: No module named 'app'`

**Solution:**
```bash
# Ensure PYTHONPATH includes src directory
export PYTHONPATH="${PYTHONPATH}:./src"

# Or install in development mode
pip install -e .
```

### Issue: Test Events Not Found

**Error:** `No such file or directory: events/api-gateway-get.json`

**Solution:**
```bash
# Ensure you're in the correct directory
cd service1  # or service2, external-api

# Verify event file exists
ls events/
```

### Issue: Permission Denied on Scripts

**Solution:**
```bash
# Make scripts executable
chmod +x run-unit-tests.sh
chmod +x run-local-invoke.sh
chmod +x run-local-api.sh
```

## Testing Workflow

### Recommended Development Workflow

1. **Write Unit Tests** (TDD approach)
   ```bash
   ./run-unit-tests.sh -v
   ```

2. **Implement Lambda Function**
   - Edit `src/app.py`
   - Run unit tests continuously

3. **Test with SAM Local Invoke**
   ```bash
   ./run-local-invoke.sh service1
   ```

4. **Test with Local API Gateway**
   ```bash
   ./run-local-api.sh service1
   curl http://127.0.0.1:3000/
   ```

5. **Run Full Test Suite**
   ```bash
   ./run-unit-tests.sh -c
   ```

6. **Deploy to AWS**
   ```bash
   sam build
   sam deploy
   ```

## Additional Resources

- [AWS SAM Developer Guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html)
- [SAM CLI Command Reference](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-command-reference.html)
- [pytest Documentation](https://docs.pytest.org/)
- [moto Documentation](http://docs.getmoto.org/)
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

## CI/CD Integration

### Example GitHub Actions Workflow

```yaml
name: Lambda Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.11'
      - name: Install dependencies
        run: pip install -r requirements-dev.txt
      - name: Run unit tests
        run: ./run-unit-tests.sh -c
      - name: Upload coverage
        uses: codecov/codecov-action@v3
```

## Summary

This local testing infrastructure provides:

✅ **Fast unit tests** for rapid development  
✅ **Local Lambda runtime simulation** for integration testing  
✅ **Local API Gateway** for end-to-end testing  
✅ **No AWS credentials required** for local testing  
✅ **Minimal external dependencies** for isolated development  
✅ **AWS best practices** alignment  

Happy testing! 🚀
