import requests
import random
import time
import os
from datetime import datetime, timezone

API_URL = os.environ.get("API_URL", "https://5un1vgmca6.execute-api.us-east-1.amazonaws.com")
NUM_VEHICLES = 15
TICK_INTERVAL = 3  # seconds between updates

def create_fleet():
    vehicles = []
    for i in range(NUM_VEHICLES):
        vehicles.append({
            "vehicle_id": f"SKELMIR-{i:03d}",
            "mission_id": f"MISSION-ALPHA-{i}",
            "position": {"latitude": random.uniform(41.3, 41.7), "longitude": random.uniform(-71.9, -71.3)},
            "depth_last_m": 0.0,
            "battery_pct": 100,
            "status": "NOMINAL",
            "nav_source": "INStinct_INS",
            "uptime_hours": 0.0
        })
    return vehicles

def update_vehicle(vehicle):
    
    vehicle["battery_pct"] = max(0, vehicle["battery_pct"] - random.uniform(0.5, 3.0))
    
    vehicle["position"]["latitude"] += random.uniform(-0.01, 0.01)
    vehicle["position"]["longitude"] += random.uniform(-0.01, 0.01)
  
    vehicle["depth_last_m"] = max(0, vehicle["depth_last_m"] + random.uniform(-5, 10))
  
    vehicle["timestamp"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")
    
    vehicle["uptime_hours"] += TICK_INTERVAL / 3600
    
    if vehicle["battery_pct"] < 10:
        vehicle["status"] = "CRITICAL"
    elif vehicle["battery_pct"] < 20:
        vehicle["status"] = "WARNING"
    else:
        vehicle["status"] = "NOMINAL"

def send_telemetry(vehicle):
    payload = {**vehicle, "sensor_readings": [
        {"type": "acoustic", "value": round(random.uniform(50, 90), 1), "unit": "dB"},
        {"type": "temperature", "value": round(random.uniform(2, 8), 1), "unit": "celsius"}
    ]}
    res = requests.post(f"{API_URL}/telemetry", json=payload)
    print(f"[{vehicle['vehicle_id']}] battery:{vehicle['battery_pct']:.0f}% status:{vehicle['status']} -> {res.status_code}")

def main():
    fleet = create_fleet()
    tick = 0
    print(f"Starting simulation: {NUM_VEHICLES} vehicles, posting to {API_URL}")
    while True:
        tick += 1
        print(f"\n--- Tick {tick} ---")
        for vehicle in fleet:
            update_vehicle(vehicle)
            send_telemetry(vehicle)
        time.sleep(TICK_INTERVAL)

if __name__ == "__main__":
    main()