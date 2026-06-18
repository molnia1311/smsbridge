#!/bin/bash
# Expected: FIRING DiskFull 3x web-01,web-02  (duplicate web-01 removed)
curl -s -X POST http://localhost:9095/alert \
  -H "Content-Type: application/json" \
  -d '{
    "alerts": [
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-01"},"annotations":{"summary":""}},
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-01"},"annotations":{"summary":""}},
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-02"},"annotations":{"summary":""}}
    ]
  }'
