# AUV Fleet Telemetry System (Project Yemoja)

Event-driven telemetry pipeline for a simulated autonomous underwater vehicle fleet. Ingests real-time sensor data via API Gateway, routes through EventBridge with content-based filtering, and fans out to three independent consumers via SNS/SQS for alerting, archival, and fleet dashboard updates.

## Architecture

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                         AUV Fleet Telemetry Pipeline                                │
│                                                                                     │
│  ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐   │
│  │  Simulator    │     │ API Gateway  │     │  EventBridge │     │  SNS Topic   │   │
│  │  (Docker)     │────►│  HTTP API    │────►│  Custom Bus  │────►│  Fan-out     │   │
│  │  15 vehicles  │POST │ /telemetry   │     │  Rule Match  │     │              │   │
│  └──────────────┘     └──────────────┘     └──────────────┘     └──────┬───────┘   │
│                                                                        │            │
│                        ┌───────────────────────┼───────────────────────┐            │
│                        │                       │                       │            │
│                        ▼                       ▼                       ▼            │
│               ┌──────────────┐        ┌──────────────┐        ┌──────────────┐     │
│               │  SQS Queue   │        │  SQS Queue   │        │  SQS Queue   │     │
│               │  ALERTING    │        │  ARCHIVAL     │        │  DASHBOARD   │     │
│               │  ┌────────┐  │        │  ┌────────┐  │        │  ┌────────┐  │     │
│               │  │  DLQ   │  │        │  │  DLQ   │  │        │  │  DLQ   │  │     │
│               │  └────────┘  │        │  └────────┘  │        │  └────────┘  │     │
│               └──────┬───────┘        └──────┬───────┘        └──────┬───────┘     │
│                      │                       │                       │              │
│                      ▼                       ▼                       ▼              │
│               ┌──────────────┐        ┌──────────────┐        ┌──────────────┐     │
│               │    Lambda    │        │    Lambda    │        │    Lambda    │     │
│               │ Alert Handler│        │Archive Handler│       │Dash Handler  │     │
│               │              │        │              │        │              │     │
│               │ Evaluate     │        │ Partition by │        │ Write fleet  │     │
│               │ battery &    │        │ date/vehicle │        │ status to    │     │
│               │ status       │        │ to S3        │        │ DynamoDB     │     │
│               └──────────────┘        └──────┬───────┘        └──────┬───────┘     │
│                                              │                       │              │
│                                              ▼                       ▼              │
│                                       ┌──────────────┐        ┌──────────────┐     │
│                                       │      S3      │        │   DynamoDB   │     │
│                                       │  Data Lake   │        │ Fleet Status │     │
│                                       │  year/mo/day │        │  vehicle_id  │     │
│                                       │  partitioned │        │  + timestamp │     │
│                                       └──────────────┘        └──────────────┘     │
│                                                                                     │
│  ┌─────────────────────────────────────────────────────────────────────────────┐    │
│  │                        Observability                                        │    │
│  │                                                                             │    │
│  │  CloudWatch Dashboard: API counts, EventBridge events, SQS depth,          │    │
│  │  Lambda invocations/errors/duration, DynamoDB latency, DLQ depth           │    │
│  │                                                                             │    │
│  │  CloudWatch Alarms: DLQ message depth > 0 → SNS email notification         │    │
│  └─────────────────────────────────────────────────────────────────────────────┘    │
│                                                                                     │
└─────────────────────────────────────────────────────────────────────────────────────┘
```

## What Was Built

**Ingestion Layer**
- HTTP API Gateway with direct EventBridge integration (no Lambda proxy)
- Custom event bus with source/detail-type pattern matching
- API Gateway IAM role scoped to `events:PutEvents` on the custom bus only

**Fan-out & Routing**
- SNS topic subscribed to EventBridge rule for one-to-many distribution
- Three SQS queues (ALERTING, ARCHIVAL, DASHBOARD) with independent consumption
- Dead-letter queues on every consumer queue with `maxReceiveCount: 4` and redrive policies

**Consumers**
- **Alert Handler** — Evaluates battery percentage and vehicle status, flags CRITICAL/WARNING conditions
- **Archive Handler** — Writes raw telemetry to S3 partitioned by `year/month/day/vehicle_id` for analytics
- **Dashboard Handler** — Writes fleet status to DynamoDB (`vehicle_id` + `timestamp` composite key) for real-time lookups

**Observability**
- CloudWatch dashboard with 10 widgets covering API Gateway, EventBridge, SQS queues, all three Lambdas, DLQ depth, and DynamoDB
- CloudWatch alarms on all DLQ queues triggering SNS email notifications on processing failures

**Simulator**
- Dockerized Python simulator generating telemetry for 15 AUVs
- Simulates battery drain, position drift, depth changes, and status transitions (NOMINAL → WARNING → CRITICAL)
- Includes acoustic and temperature sensor readings

## Key Decisions

| Decision | Rationale |
| --- | --- |
| **API Gateway → EventBridge (no Lambda proxy)** | Direct service integration eliminates a Lambda invocation on every request. Lower latency, lower cost, fewer failure points. |
| **EventBridge → SNS → SQS (not EventBridge → SQS directly)** | SNS fan-out decouples routing from consumption. Adding a fourth consumer means one new SQS subscription, not a new EventBridge target + IAM policy. |
| **Per-consumer DLQ with redrive** | A poison message in the alert path doesn't block archival or dashboard updates. Each consumer fails independently. |
| **S3 partitioning by date/vehicle** | Enables cost-effective Athena queries without scanning the full bucket. Partition structure supports time-range and per-vehicle analysis. |
| **DynamoDB PAY_PER_REQUEST** | No traffic prediction needed for a bursty telemetry workload. Scales to zero when simulator isn't running. |
| **Reusable Lambda module with conditional custom policies** | Base policy (SQS + CloudWatch Logs) is shared. Custom policies (S3 write, DynamoDB write) are conditionally attached via `count` on `custom_policy_actions`. Avoids three separate Lambda modules. |

## Data Flow

```
Simulator POST /telemetry
    │
    ▼
API Gateway validates → PutEvents to custom EventBridge bus
    │
    ▼
EventBridge rule matches source: "yemoja.telemetry" → SNS topic
    │
    ▼
SNS fans out to 3 SQS queues (each with DLQ)
    │
    ├─► ALERTING queue → Lambda evaluates battery/status → logs alert
    ├─► ARCHIVAL queue → Lambda writes to S3 (year/month/day/vehicle/)
    └─► DASHBOARD queue → Lambda writes to DynamoDB (vehicle_id + timestamp)
```

## Telemetry Payload

```json
{
  "vehicle_id": "SKELMIR-003",
  "mission_id": "MISSION-ALPHA-3",
  "timestamp": "2025-03-09T14:32:00Z",
  "position": { "latitude": 41.52, "longitude": -71.61 },
  "depth_last_m": 42.7,
  "battery_pct": 73,
  "status": "NOMINAL",
  "nav_source": "INStinct_INS",
  "uptime_hours": 12.4,
  "sensor_readings": [
    { "type": "acoustic", "value": 67.3, "unit": "dB" },
    { "type": "temperature", "value": 4.2, "unit": "celsius" }
  ]
}
```

## Repository Structure

```
├── main.tf                    # Root module - wires all components together
├── variables.tf               # Project-level variables (name, env, region)
├── provider.tf                # AWS provider config with default tags
├── backend.tf                 # S3 remote state backend
├── alarms.tf                  # CloudWatch alarms on DLQ depth
├── cloudwatch.tf              # CloudWatch dashboard (10 widgets)
├── modules/
│   ├── api/                   # API Gateway HTTP API → EventBridge integration
│   ├── eventbridge/           # Custom event bus, rules, SNS target
│   ├── sns/                   # Fan-out topic with SQS subscriptions
│   ├── sqs/                   # Consumer queues + DLQs with redrive
│   ├── lambda/                # Reusable Lambda module (base + custom IAM)
│   ├── dynamodb/              # Fleet status table (vehicle_id + timestamp)
│   └── s3/                    # Telemetry archive bucket (versioned, private)
├── lambda/
│   ├── alert_handler/         # Battery/status evaluation
│   ├── archive_handler/       # S3 partitioned writes
│   ├── dashboard_handler/     # DynamoDB fleet status updates
│   └── packages/              # Zipped Lambda deployment packages
└── simulator/
    ├── simulator.py           # 15-vehicle fleet telemetry generator
    ├── Dockerfile             # Containerized simulator
    └── requirements.txt
```

## Running the Simulator

```bash
# Set the API Gateway URL
export API_URL="https://<your-api-id>.execute-api.us-east-1.amazonaws.com"

# Run directly
cd simulator
pip install -r requirements.txt
python simulator.py

# Or via Docker
docker build -t yemoja-sim simulator/
docker run -e API_URL=$API_URL yemoja-sim
```

## Cost Estimate

| Component | Monthly Cost |
| --- | --- |
| API Gateway (HTTP API) | ~$1/million requests |
| EventBridge | $1/million events |
| SNS | Negligible (SQS delivery) |
| SQS (6 queues) | ~$0.40/million requests |
| Lambda (3 functions) | ~$0.20/million invocations |
| DynamoDB (on-demand) | ~$1.25/million writes |
| S3 | ~$0.023/GB stored |
| **Idle cost** | **~$0/month** |

*Fully serverless — scales to zero when simulator isn't running.*

## Tech Stack

- **IaC:** Terraform with reusable modules
- **AWS Services:** API Gateway (HTTP), EventBridge, SNS, SQS, Lambda, DynamoDB, S3, CloudWatch
- **Patterns:** Event-driven architecture, fan-out/fan-in, dead-letter queues, content-based routing
- **Languages:** HCL (83%), Python (16%), Dockerfile

---

*Built as a portfolio project demonstrating event-driven AWS architecture patterns.*
