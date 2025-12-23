import json
import os


def lambda_handler(event, context):
    """
    Service1 Lambda handler
    
    Returns service name and region information
    
    Args:
        event: API Gateway event
        context: Lambda context
        
    Returns:
        dict: Response with statusCode and body
    """
    return {
        "statusCode": 200,
        "body": json.dumps({
            "service": "service1",
            "region": os.environ.get('AWS_REGION', 'local')
        }),
    }
