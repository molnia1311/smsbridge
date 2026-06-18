#!/bin/bash
# Expected: RESOLVED DiskFull web-01: disk ok
curl -s -X POST http://localhost:9095/alert \
  -H "Content-Type: application/json" \
  -d '{
    "alerts": [
      {
        "status": "resolved",
        "labels": { "alertname": "DiskFull", "instance": "web-01" },
        "annotations": { "summary": "disk ok" }
      }
    ]
  }'
