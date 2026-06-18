#!/bin/bash
curl -X POST http://localhost:9095/alert \
  -H "Content-Type: application/json" \
  -d '{
    "commonLabels": {
      "env": "prod"
    },
    "alerts": [
      {
        "status": "firing",
        "labels": {
          "alertname": "alertname"
        },
        "annotations": {
          "summary": "this is a summary"
        }
      }
    ]
  }'
