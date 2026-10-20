# REST API examples

Build your own feedback UI and send the result with one HTTP call. Every example posts to
`https://api.fpulse.app/v1/feedback` with your project API key (`fp_...`) in the `X-API-Key` header.
They are the same examples as on [fpulse.app/docs](https://fpulse.app/docs?utm_source=github&utm_medium=examples).

| Language | Files | Run or use |
|----------|-------|------------|
| cURL | [`curl/`](curl) | `sh curl/submit-feedback.sh` after putting in your key |
| JavaScript | [`javascript/submit-feedback.js`](javascript/submit-feedback.js), [`react/FeedbackWidget.jsx`](javascript/react/FeedbackWidget.jsx) | Browser `fetch`, no package needed |
| Python | [`python/feedback_pulse.py`](python/feedback_pulse.py) | `pip install requests`, then `python feedback_pulse.py` |
| Swift (iOS, macOS) | [`swift/QuickStart.swift`](swift/QuickStart.swift) | Uses the [Swift package](https://github.com/Fpulse-App/fpulse-ios-sdk) |
| Kotlin (Android) | [`kotlin/FeedbackPulse.kt`](kotlin/FeedbackPulse.kt) | kotlinx.coroutines; `org.json` comes with Android |
| Dart / Flutter | [`dart/`](dart) | `http` package |
| Java | [`java/`](java) | Java 11+ `HttpClient` and Gson, Spring Boot example |
| PHP | [`php/`](php) | cURL extension, Laravel example |
| Go | [`go/feedbackpulse.go`](go/feedbackpulse.go) | Standard library only |
| Rust | [`rust/`](rust) | `FPULSE_API_KEY=fp_... cargo run` |
| Ruby | [`ruby/`](ruby) | Standard library only, Rails example |
| C# / .NET | [`csharp/`](csharp) | `HttpClient`, ASP.NET Core example |
| Elixir | [`elixir/`](elixir) | `httpoison` and `jason`, Phoenix example |

Files named `*-example.*` are snippets showing how to wire the client into a framework.

## Request

```json
{
  "sentiment": "positive",
  "comment": "Optional text, up to 5,000 characters",
  "app_version": "2.1.0",
  "app_type": "ios",
  "screen_id": "checkout",
  "user_identifier": "optional user id or email",
  "environment": "production",
  "device_info": { "os": "iOS", "os_version": "18.1", "device_model": "iPhone16,1" },
  "metadata": { "any": "custom data" }
}
```

- Required: `sentiment` (`positive` or `negative`), `app_version` and `app_type` (`ios`, `android`, `web`, `desktop` or `other`).
- Ratings instead of thumbs: send `rating_type` (`emoji` or `stars` with a 1-5 score, `nps` with 0-10) and `rating_score`.
  The sentiment is then worked out for you.
- Several at once: `POST /v1/feedback/batch` with `{"feedbacks": [...]}`.

## Response

`201` with `{"success": true, "feedback_id": 123}`. Errors return `success: false` with an `error` message and a `code`:
`VALIDATION_ERROR` (400, see `details`), `MISSING_API_KEY` or `INVALID_API_KEY` (401), `LIMIT_EXCEEDED` (403) or `RATE_LIMITED` (429, wait for `Retry-After` seconds).

## Reading feedback

`GET /v1/feedback` returns your feedback with filters. It needs the **secret read key** (`fpsk_...`), never the app key.
See [`curl/read-feedback.sh`](curl/read-feedback.sh). Call it from your server only.
