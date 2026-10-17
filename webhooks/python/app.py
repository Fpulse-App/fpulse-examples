"""
Receive F-Pulse App webhooks and verify their signature.

Run:  pip install flask
      FPULSE_WEBHOOK_SECRET=your_secret flask --app app run --port 3000
Then add http(s)://your-server/fpulse-webhook as a webhook URL in the dashboard (Integrations > Webhooks).
"""
import hashlib
import hmac
import os

from flask import Flask, abort, request

SECRET = os.environ.get("FPULSE_WEBHOOK_SECRET", "")
app = Flask(__name__)


def valid_signature(raw_body: bytes, header: str) -> bool:
    if not SECRET:
        return True  # No secret set in the dashboard: requests are not signed
    if not header or not header.startswith("sha256="):
        return False
    expected = hmac.new(SECRET.encode(), raw_body, hashlib.sha256).hexdigest()
    return hmac.compare_digest(expected, header[len("sha256="):])


@app.post("/fpulse-webhook")
def fpulse_webhook():
    raw = request.get_data()  # Verify the raw bytes, before parsing
    if not valid_signature(raw, request.headers.get("X-Webhook-Signature", "")):
        abort(401)
    event = request.get_json()
    # event["event"]: "feedback.positive", "feedback.negative" or "daily.summary"
    if event["event"] == "feedback.negative":
        data = event["data"]
        print("Negative feedback:", data.get("comment") or "(no comment)", "on", data.get("screen_id"))
    else:
        print("Event:", event["event"], event.get("data"))
    return {"ok": True}
