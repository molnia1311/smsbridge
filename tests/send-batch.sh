#!/bin/bash
# Expected: FIRING DiskFull 3x web-01,web-02,web-03
curl -s -X POST http://localhost:9095/alert \
  -H "Content-Type: application/json" \
  -d '{
    "alerts": [
      {
        "status": "firing",
        "labels": { "alertname": "DiskFull", "instance": "web-01" },
        "annotations": { "summary": "disk at 95%" }
      },
      {
        "status": "firing",
        "labels": { "alertname": "DiskFull", "instance": "web-02" },
        "annotations": { "summary": "disk at 90%" }
      },
      {
        "status": "firing",
        "labels": { "alertname": "DiskFull", "instance": "web-03" },
        "annotations": { "summary": "disk at 88%" }
      }
    ]
  }'
