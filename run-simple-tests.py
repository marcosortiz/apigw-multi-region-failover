#!/usr/bin/env python3
"""
Simple test runner that validates Lambda functions without requiring pytest
Can be used in environments where pytest is not installed
"""
import sys
import json
import os
from pathlib import Path


class Colors:
    GREEN = '\033[0;32m'
    BLUE = '\033[0;34m'
    RED = '\033[0;31m'
    YELLOW = '\033[1;33m'
    NC = '\033[0m'  # No Color


def test_lambda_function(service_name, service_path):
    """Test a Lambda function by importing and invoking it"""
    print(f"\n{Colors.BLUE}Testing {service_name}...{Colors.NC}")
    
    # Add src directory to path
    src_path = Path(service_path) / 'src'
    sys.path.insert(0, str(src_path))
    
    try:
        # Import the Lambda handler
        import app
        
        # Test 1: Basic invocation
        print(f"  → Test: Basic invocation")
        event = {}
        context = {}
        response = app.lambda_handler(event, context)
        
        assert response['statusCode'] == 200, f"Expected 200, got {response['statusCode']}"
        body = json.loads(response['body'])
        assert 'service' in body, "Response body missing 'service' key"
        assert 'region' in body, "Response body missing 'region' key"
        print(f"    {Colors.GREEN}✓ Basic invocation passed{Colors.NC}")
        
        # Test 2: Service name validation
        print(f"  → Test: Service name validation")
        expected_service = service_name.lower().replace('external-api', 'external-api')
        if 'external' in service_name:
            expected_service = 'external-api'
        else:
            expected_service = service_name.lower()
        
        assert body['service'] == expected_service, f"Expected service '{expected_service}', got '{body['service']}'"
        print(f"    {Colors.GREEN}✓ Service name validation passed{Colors.NC}")
        
        # Test 3: Region handling
        print(f"  → Test: Region from environment")
        os.environ['AWS_REGION'] = 'us-west-2'
        response = app.lambda_handler(event, context)
        body = json.loads(response['body'])
        assert body['region'] == 'us-west-2', f"Expected region 'us-west-2', got '{body['region']}'"
        print(f"    {Colors.GREEN}✓ Region handling passed{Colors.NC}")
        
        # Test 4: API Gateway event structure
        print(f"  → Test: API Gateway event handling")
        api_event = {
            'resource': '/',
            'path': '/',
            'httpMethod': 'GET',
            'headers': {'Accept': 'application/json'},
            'body': None
        }
        response = app.lambda_handler(api_event, context)
        assert response['statusCode'] == 200, "Failed with API Gateway event"
        print(f"    {Colors.GREEN}✓ API Gateway event handling passed{Colors.NC}")
        
        print(f"{Colors.GREEN}✓ All tests passed for {service_name}{Colors.NC}")
        return True
        
    except Exception as e:
        print(f"{Colors.RED}✗ Test failed: {str(e)}{Colors.NC}")
        import traceback
        traceback.print_exc()
        return False
    finally:
        # Clean up path
        if str(src_path) in sys.path:
            sys.path.remove(str(src_path))
        # Clean up imported module
        if 'app' in sys.modules:
            del sys.modules['app']


def main():
    """Run tests for all Lambda functions"""
    print(f"{Colors.BLUE}{'='*50}{Colors.NC}")
    print(f"{Colors.BLUE}Lambda Function Unit Tests{Colors.NC}")
    print(f"{Colors.BLUE}{'='*50}{Colors.NC}")
    
    base_path = Path(__file__).parent
    
    services = [
        ('service1', base_path / 'service1'),
        ('service2', base_path / 'service2'),
        ('external-api', base_path / 'external-api'),
    ]
    
    results = {}
    
    for service_name, service_path in services:
        if service_path.exists():
            results[service_name] = test_lambda_function(service_name, service_path)
        else:
            print(f"{Colors.YELLOW}⚠ Skipping {service_name}: Directory not found{Colors.NC}")
            results[service_name] = None
    
    print(f"\n{Colors.BLUE}{'='*50}{Colors.NC}")
    print(f"{Colors.BLUE}Test Summary{Colors.NC}")
    print(f"{Colors.BLUE}{'='*50}{Colors.NC}")
    
    passed = sum(1 for v in results.values() if v is True)
    failed = sum(1 for v in results.values() if v is False)
    skipped = sum(1 for v in results.values() if v is None)
    
    for service_name, result in results.items():
        if result is True:
            print(f"  {Colors.GREEN}✓ {service_name}: PASSED{Colors.NC}")
        elif result is False:
            print(f"  {Colors.RED}✗ {service_name}: FAILED{Colors.NC}")
        else:
            print(f"  {Colors.YELLOW}⚠ {service_name}: SKIPPED{Colors.NC}")
    
    print(f"\n{Colors.BLUE}Total: {passed} passed, {failed} failed, {skipped} skipped{Colors.NC}")
    
    if failed > 0:
        print(f"\n{Colors.RED}Some tests failed!{Colors.NC}")
        sys.exit(1)
    else:
        print(f"\n{Colors.GREEN}All tests passed!{Colors.NC}")
        sys.exit(0)


if __name__ == '__main__':
    main()
