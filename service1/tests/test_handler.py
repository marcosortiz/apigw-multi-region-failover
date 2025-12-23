"""
Unit tests for Service1 Lambda function
"""
import json
import os
import pytest
import sys
from pathlib import Path

# Add src directory to path
sys.path.insert(0, str(Path(__file__).parent.parent / 'src'))

from app import lambda_handler


class TestService1Lambda:
    """Test cases for Service1 Lambda handler"""
    
    def test_lambda_handler_returns_200(self):
        """Test that lambda handler returns 200 status code"""
        event = {}
        context = {}
        
        response = lambda_handler(event, context)
        
        assert response['statusCode'] == 200
    
    def test_lambda_handler_returns_json_body(self):
        """Test that lambda handler returns valid JSON body"""
        event = {}
        context = {}
        
        response = lambda_handler(event, context)
        body = json.loads(response['body'])
        
        assert 'service' in body
        assert 'region' in body
    
    def test_lambda_handler_service_name(self):
        """Test that lambda handler returns correct service name"""
        event = {}
        context = {}
        
        response = lambda_handler(event, context)
        body = json.loads(response['body'])
        
        assert body['service'] == 'service1'
    
    def test_lambda_handler_region_from_env(self):
        """Test that lambda handler reads region from environment"""
        event = {}
        context = {}
        
        # Set AWS_REGION environment variable
        os.environ['AWS_REGION'] = 'us-west-2'
        
        response = lambda_handler(event, context)
        body = json.loads(response['body'])
        
        assert body['region'] == 'us-west-2'
    
    def test_lambda_handler_default_region(self):
        """Test that lambda handler returns default region when env not set"""
        event = {}
        context = {}
        
        # Remove AWS_REGION if it exists
        if 'AWS_REGION' in os.environ:
            del os.environ['AWS_REGION']
        
        response = lambda_handler(event, context)
        body = json.loads(response['body'])
        
        assert body['region'] == 'local'
    
    def test_lambda_handler_with_api_gateway_event(self):
        """Test lambda handler with API Gateway proxy event structure"""
        event = {
            'resource': '/',
            'path': '/',
            'httpMethod': 'GET',
            'headers': {
                'Accept': 'application/json',
                'Host': 'example.com'
            },
            'queryStringParameters': None,
            'pathParameters': None,
            'body': None,
            'isBase64Encoded': False
        }
        context = {}
        
        response = lambda_handler(event, context)
        
        assert response['statusCode'] == 200
        body = json.loads(response['body'])
        assert body['service'] == 'service1'
