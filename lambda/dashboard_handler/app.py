# send fleet data and status data to dynamodb table 
import json
import os
import boto3
from botocore.exceptions import ClientError

# aws clients
dynamodb = boto3.resource('dynamodb')
# env variables
TABLE_NAME = os.environ['DYNAMODB_TABLE_NAME']

def lambda_handler(event, context):
    for record in event["Records"]:
        try: 
            telemetry = extract_data(record)
            write_to_dynamodb(telemetry)
        except Exception as e:
            print(f"Error processing record: {e}")

def extract_data(record):
    sns_envelope = json.loads(record["body"])
    eb_envelope = json.loads(sns_envelope["Message"])
    telemetry = eb_envelope["detail"]
 
    
    return telemetry


def write_to_dynamodb(telemetry):
    table = dynamodb.Table(TABLE_NAME)
    
    table.put_item(
        Item={
            'vehicle_id': telemetry['vehicle_id'],
            'timestamp': telemetry['timestamp'],
            'mission_id': telemetry['mission_id'],
            'latitude': str(telemetry['position']['latitude']),
            'longitude': str(telemetry['position']['longitude']),
            'depth_last_m': str(telemetry['depth_last_m']),
            'battery_pct': telemetry['battery_pct'],
            'status': telemetry['status'],
            'nav_source': telemetry['nav_source'],
            'uptime_hours': str(telemetry['uptime_hours'])
        }
    )
    
    print(f"Updated: {telemetry['vehicle_id']} at {telemetry['timestamp']}")

 