# Lambda Local Testing - Quick Reference

## Prerequisites Setup
```bash
# Install Python dependencies
pip install -r requirements-dev.txt

# Verify SAM CLI (for local Lambda testing)
sam --version

# Verify Docker (required by SAM CLI)
docker --version
```

## Quick Start Testing

### 1. Run Unit Tests (No Dependencies Required)
```bash
# Simple Python-based tests (fastest)
python3 run-simple-tests.py

# Or with pytest (if installed)
./run-unit-tests.sh
```

### 2. Test Lambda Functions Locally with SAM
```bash
# Test all Lambda functions
./run-local-invoke.sh

# Test specific service
./run-local-invoke.sh service1
./run-local-invoke.sh service2
./run-local-invoke.sh external-api
```

### 3. Start Local API Gateway
```bash
# Service1 on port 3000
./run-local-api.sh service1

# Service2 on port 3001
./run-local-api.sh service2

# External API on port 3002
./run-local-api.sh external-api
```

Then test with curl:
```bash
curl http://127.0.0.1:3000/
curl http://127.0.0.1:3001/
curl http://127.0.0.1:3002/
```

## With Makefile

```bash
# Show all available commands
make help

# Quick validation and unit tests
make quick-test

# Run unit tests
make test-unit

# Test with coverage
make test-coverage

# Test locally with SAM CLI
make test-local

# Start local APIs
make start-api-service1  # port 3000
make start-api-service2  # port 3001
make start-api-external  # port 3002

# Clean up generated files
make clean
```

## Testing Workflow

1. **During Development**: `python3 run-simple-tests.py` (fastest)
2. **Before Commit**: `./run-unit-tests.sh -c` (with coverage)
3. **Before Deploy**: `./run-local-invoke.sh` (SAM CLI test)
4. **For Manual Testing**: `./run-local-api.sh service1` (interactive)

## Common Commands

```bash
# Validate Python syntax
python3 -m py_compile service1/src/app.py

# Run single service test
cd service1
python3 -m pytest tests/ -v

# Invoke Lambda with custom event
cd service1
sam local invoke Service1LambdaRegionalApi --event events/api-gateway-get.json

# Build Lambda function
cd service1
sam build

# Start API with warm containers (faster)
cd service1
sam local start-api --warm-containers EAGER
```

## Expected Test Output

### Unit Tests
```
✓ service1: PASSED
✓ service2: PASSED  
✓ external-api: PASSED
```

### Lambda Response
```json
{
  "statusCode": 200,
  "body": "{\"service\": \"service1\", \"region\": \"us-east-1\"}"
}
```

## Troubleshooting

| Issue | Solution |
|-------|----------|
| `sam: command not found` | Install AWS SAM CLI |
| `Docker daemon not running` | Start Docker Desktop |
| `Port already in use` | Use different port: `./run-local-api.sh service1 3003` |
| `Module not found` | Run from repository root directory |
| `Permission denied` | Make scripts executable: `chmod +x *.sh` |

## Files Overview

```
├── service1/
│   ├── src/app.py              # Lambda function code
│   ├── tests/test_handler.py   # Unit tests
│   ├── events/                 # Test event payloads
│   └── template.yaml           # SAM template
├── service2/                   # Same structure
├── external-api/               # Same structure
├── run-simple-tests.py         # Python test runner (no deps)
├── run-unit-tests.sh           # Pytest test runner
├── run-local-invoke.sh         # SAM local invoke
├── run-local-api.sh            # SAM local API
├── requirements-dev.txt        # Dev dependencies
├── pytest.ini                  # Pytest configuration
├── Makefile                    # Make targets
└── TESTING.md                  # Full documentation
```

For detailed documentation, see [TESTING.md](TESTING.md)
