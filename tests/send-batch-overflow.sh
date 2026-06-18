#!/bin/bash
# Expected: FIRING DiskFull 5x web-01,web-02,web-03 +2 more
curl -s -X POST http://localhost:9095/alert \
  -H "Content-Type: application/json" \
  -d '{
    "alerts": [
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-01"},"annotations":{"summary":""}},
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-02"},"annotations":{"summary":""}},
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-03"},"annotations":{"summary":""}},
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-04"},"annotations":{"summary":""}},
      {"status":"firing","labels":{"alertname":"DiskFull","instance":"web-05"},"annotations":{"summary":""}}
    ]
  }'
