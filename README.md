<p align="center">
  <a href="https://fpulse.app?utm_source=github&utm_medium=examples"><img src="https://fpulse.app/static/images/logo100x100.png" alt="F-Pulse App" width="80" height="80"></a>
</p>

<h1 align="center">F-Pulse App examples</h1>

<p align="center">
  Collect user feedback from your website or app: a one-line feedback widget, a REST API with examples in 13 languages, and webhooks.
</p>

<p align="center">
  <a href="https://fpulse.app?utm_source=github&utm_medium=examples">Website</a> ·
  <a href="https://fpulse.app/docs?utm_source=github&utm_medium=examples">Docs</a> ·
  <a href="https://fpulse.app/static/openapi.json">OpenAPI</a> ·
  <a href="https://github.com/ztuskes/feedbackPulse">iOS SDK</a> ·
  <a href="https://fpulse.app/pricing?utm_source=github&utm_medium=examples">Pricing</a>
</p>

---

[F-Pulse App](https://fpulse.app?utm_source=github&utm_medium=examples) collects ratings and comments from your users (thumbs, emoji, stars or NPS),
shows sentiment trends in a dashboard and uses AI to tell you what to fix first.
The Free plan includes 1,000 feedbacks a month, no credit card needed.

This repository has copy-paste examples for every way to send feedback to F-Pulse App.

## Pick your path

| You have | Use | Start here |
|----------|-----|------------|
| A website, web app or online store | The **feedback widget**: one `<script>` tag, no coding | [`website-widget/`](website-widget) |
| A WordPress site | The **WordPress plugin** | [`website-widget/wordpress-plugin/`](website-widget/wordpress-plugin) |
| An iOS or macOS app | The **Swift SDK** with a ready-made SwiftUI sheet | [ztuskes/feedbackPulse](https://github.com/ztuskes/feedbackPulse) |
| An Android, Flutter, desktop or backend app | The **REST API** with your own UI | [`rest-api/`](rest-api) |
| A server that should react to new feedback | **Webhooks** | [`webhooks/`](webhooks) |

## 1. Get your keys

1. [Create a free account](https://fpulse.app/auth/register?utm_source=github&utm_medium=examples) and a project.
2. **Widget ID**: on the **Widget** page of the dashboard, turn the widget on and copy the snippet.
3. **API key** (`fp_...`): shown when you create a project. It can only *send* feedback, so it is safe inside apps.
4. **Read key** (`fpsk_...`): only needed to *read* feedback through the API. Create it under
   **Projects > Settings** and keep it on your server. Never ship it in an app or website.

## 2. Send your first feedback

```sh
curl -X POST https://api.fpulse.app/v1/feedback \
  -H "Content-Type: application/json" \
  -H "X-API-Key: fp_your_api_key_here" \
  -d '{"sentiment": "positive", "comment": "Hello from cURL", "app_version": "1.0.0", "app_type": "other", "environment": "development"}'
```

It shows up in your dashboard right away (switch the environment to **Development** to see it).

## Good to know

- **Environments**: send `"environment": "development"` (or add `?env=dev` to the widget URL) from test builds,
  so test feedback stays out of your real numbers.
- **Rate limits** per project: 100 requests a minute on Free, 1,000 on Pro, 10,000 on Enterprise.
  Over the limit the API answers `429` with a `Retry-After` header.
- **Base URL**: `https://api.fpulse.app/v1` (also available as `https://fpulse.app/api/v1`).
- Full reference: [fpulse.app/docs](https://fpulse.app/docs?utm_source=github&utm_medium=examples) and the [OpenAPI spec](https://fpulse.app/static/openapi.json).

## Contributing

Found a bug in an example or want to add a language? Open an issue or a pull request.

## License

The examples are [MIT licensed](LICENSE). The WordPress plugin in `website-widget/wordpress-plugin/` is GPLv2 or later,
as WordPress requires.
