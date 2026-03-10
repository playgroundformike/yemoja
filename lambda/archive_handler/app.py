# Send raw S3 Data Lake

 

import json
import datetime
import os
import boto3
from botocore.exceptions import ClientError 

s3 = boto3.client('s3')
BUCKET = os.environ["BUCKET_NAME"]

def lambda_handler(event, context):
    for record in event["Records"]:
        try:        
            telemetry = extract_data(record)
            s3_key = extract_for_s3_key(telemetry)
            write_to_s3(BUCKET,s3_key,telemetry)
        except Exception as e:
            print(f"Error processing record: {e}")

def extract_for_s3_key(telemetry):
    vehicle = telemetry["vehicle_id"]
    
    iso_timestamp = telemetry['timestamp']
    dt_object = datetime.datetime.fromisoformat(iso_timestamp.replace("Z", "+00:00"))
    s3_key = f"year={dt_object.year}/month={dt_object.month:02d}/day={dt_object.day:02d}/{vehicle}/{iso_timestamp}.json"

    return s3_key

def extract_data(record):
    sns_envelope = json.loads(record["body"])
    eb_envelope = json.loads(sns_envelope["Message"])
    telemetry = eb_envelope["detail"]

    
    return telemetry

def write_to_s3(BUCKET,s3_key,telemetry):
  try:
    res = s3.put_object(
    Bucket=BUCKET,
    Key=s3_key,
    Body=json.dumps(telemetry)
    )
    print(f"Archived: s3://{BUCKET}/{s3_key}")
    return res
  except ClientError as e:
    print(f"Error writing to S3: {e}")
    return {}
 
 