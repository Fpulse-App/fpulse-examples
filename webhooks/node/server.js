// Receive F-Pulse App webhooks and verify their signature.
// Run: FPULSE_WEBHOOK_SECRET=your_secret node server.js   (Node 18+, no dependencies)
// Then add http(s)://your-server/fpulse-webhook as a webhook URL in the dashboard (Integrations > Webhooks).
const http = require('http');
const crypto = require('crypto');

const SECRET = process.env.FPULSE_WEBHOOK_SECRET || '';
const PORT = process.env.PORT || 3000;

function validSignature(rawBody, header) {
  if (!SECRET) return true; // No secret set in the dashboard: requests are not signed
  if (!header || !header.startsWith('sha256=')) return false;
  const expected = crypto.createHmac('sha256', SECRET).update(rawBody).digest('hex');
  const received = header.slice('sha256='.length);
  return expected.length === received.length &&
    crypto.timingSafeEqual(Buffer.from(expected), Buffer.from(received));
}

http.createServer((req, res) => {
  if (req.method !== 'POST' || req.url !== '/fpulse-webhook') {
    res.writeHead(404).end();
    return;
  }
  const chunks = [];
  req.on('data', (c) => chunks.push(c));
  req.on('end', () => {
    const raw = Buffer.concat(chunks);
    if (!validSignature(raw, req.headers['x-webhook-signature'])) {
      res.writeHead(401).end('bad signature');
      return;
    }
    const event = JSON.parse(raw.toString('utf8'));
    // event.event: "feedback.positive", "feedback.negative" or "daily.summary"
    if (event.event === 'feedback.negative') {
      console.log('Negative feedback:', event.data.comment || '(no comment)', 'on', event.data.screen_id);
    } else {
      console.log('Event:', event.event, JSON.stringify(event.data));
    }
    res.writeHead(200, { 'Content-Type': 'application/json' }).end('{"ok":true}');
  });
}).listen(PORT, () => console.log(`Listening on http://localhost:${PORT}/fpulse-webhook`));
