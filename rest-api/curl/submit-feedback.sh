#!/bin/sh
# Submit one feedback. Replace the key with your project API key (fp_...).
curl -X POST https://api.fpulse.app/v1/feedback \
  -H "Content-Type: application/json" \
  -H "X-API-Key: fp_your_api_key_here" \
  -d '{
    "sentiment": "positive",
    "comment": "Great product!",
    "app_version": "2.1.0",
    "app_type": "web",
    "screen_id": "checkout"
  }'
