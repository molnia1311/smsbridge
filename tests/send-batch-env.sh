#!/bin/bash
# Expected: prod FIRING DiskFull 3x web-01,web-02,web-03
curl -s -X POST http://localhost:9095/alert \
  -H "Content-Type: application/json" \
  -d '{
    "commonLabels": { "env": "prod" },
    "alerts": [
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-01"},"annotations":{"summary":""}},
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-02"},"annotations":{"summary":""}},
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-03"},"annotations":{"summary":""}}
    ]
  }'
