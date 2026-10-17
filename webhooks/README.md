# Webhooks

F-Pulse App can POST an event to your server for every new feedback (Pro and Enterprise plans).
Set it up in the dashboard under **Integrations > Webhooks**.

## Events

| Event | When |
|-------|------|
| `feedback.positive` | A positive feedback was received |
| `feedback.negative` | A negative feedback was received |
| `daily.summary` | Once a day, a summary of the day's feedback |

## Payload

```json
{
  "event": "feedback.negative",
  "timestamp": "2026-10-18T10:30:00",
  "data": {
    "id": 12345,
    "sentiment": "negative",
    "rating": null,
    "rating_type": "thumbs",
    "comment": "The export button does nothing",
    "screen_id": "/reports",
    "app_version": "2.1.0",
    "platform": "web",
    "environment": "production",
    "created_at": "2026-10-18T10:30:00Z"
  }
}
```

Headers: `Content-Type: application/json`, `X-Webhook-Event: <event>` and, when you set a secret,
`X-Webhook-Signature: sha256=<hex>`.

## Verifying the signature

The signature is an HMAC-SHA256 of the **raw request body** with your webhook secret, in hex.
Always verify the raw bytes before parsing the JSON, and compare in constant time.

- [`node/server.js`](node/server.js): Node 18+, no dependencies
- [`python/app.py`](python/app.py): Flask

Your endpoint should answer with a 2xx status within 10 seconds. Redirects are not followed.
