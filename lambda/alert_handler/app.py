# SNS Topic to send emails and alerts
import json


def lambda_handler(event, context):
    for record in event["Records"]:
        try:
            telemetry = extract_data(record)
            evaluate_alert(telemetry)
        except Exception as e:
            print(f"Error processing record: {e}")

def extract_data(record):
    sns_envelope = json.loads(record["body"])
    eb_envelope = json.loads(sns_envelope["Message"])
    telemetry = eb_envelope["detail"]

    
    return telemetry

def evaluate_alert(telemetry):
  vehicle = telemetry["vehicle_id"]
  battery_pct = telemetry["battery_pct"] 
  vehicle_status = telemetry["status"] 
  
  if battery_pct < 20 or vehicle_status == "CRITICAL":
    print(f"Alert: {vehicle} - battery:{battery_pct}%, status:{vehicle_status}")
  else:
    print(f"OK: {vehicle} - battery:{battery_pct}%, status:{vehicle_status}")