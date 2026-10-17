#!/bin/sh
# Read feedback from your server. This needs the SECRET read key (fpsk_...),
# created under Projects > Settings > Read Key for the API. The public fp_ key gets 403 READ_KEY_REQUIRED.
# Never put the read key in a website or mobile app.

# Latest feedback
curl -H "X-API-Key: fpsk_your_read_key" \
  "https://api.fpulse.app/v1/feedback"

# Negative feedback from the last 30 days, page 2
curl -H "X-API-Key: fpsk_your_read_key" \
  "https://api.fpulse.app/v1/feedback?period=30d&sentiment=negative&page=2"
