import com.google.gson.Gson;
import com.google.gson.annotations.SerializedName;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.time.Duration;
import java.util.HashMap;
import java.util.Map;

public class FeedbackPulse {
    private static final String BASE_URL = "https://api.fpulse.app/v1";
    private final HttpClient httpClient;
    private final Gson gson;
    private final String apiKey;
    private final String appVersion;
    private final String appType;
    private final String environment;

    public FeedbackPulse(String apiKey, String appVersion) {
        this(apiKey, appVersion, "desktop", "production");
    }

    public FeedbackPulse(String apiKey, String appVersion, String appType, String environment) {
        this.apiKey = apiKey;
        this.appVersion = appVersion;
        this.appType = appType;
        this.environment = environment;
        this.httpClient = HttpClient.newBuilder()
            .connectTimeout(Duration.ofSeconds(30))
            .build();
        this.gson = new Gson();
    }

    public record FeedbackResult(
        boolean success,
        @SerializedName("feedback_id") Integer feedbackId,
        String error
    ) {}

    public FeedbackResult submit(String sentiment, String comment, String screenId) {
        return submit(sentiment, comment, screenId, null, null);
    }

    public FeedbackResult submit(
        String sentiment,
        String comment,
        String screenId,
        String userIdentifier,
        Map<String, Object> metadata
    ) {
        try {
            Map<String, Object> body = new HashMap<>();
            body.put("sentiment", sentiment);
            body.put("app_version", appVersion);
            body.put("app_type", appType);
            body.put("environment", environment);
            body.put("device_info", getDeviceInfo());

            if (comment != null) body.put("comment", comment);
            if (screenId != null) body.put("screen_id", screenId);
            if (userIdentifier != null) body.put("user_identifier", userIdentifier);
            if (metadata != null) body.put("metadata", metadata);

            HttpRequest request = HttpRequest.newBuilder()
                .uri(URI.create(BASE_URL + "/feedback"))
                .header("Content-Type", "application/json")
                .header("X-API-Key", apiKey)
                .POST(HttpRequest.BodyPublishers.ofString(gson.toJson(body)))
                .build();

            HttpResponse<String> response = httpClient.send(
                request,
                HttpResponse.BodyHandlers.ofString()
            );

            return gson.fromJson(response.body(), FeedbackResult.class);
        } catch (Exception e) {
            return new FeedbackResult(false, null, e.getMessage());
        }
    }

    private Map<String, String> getDeviceInfo() {
        Map<String, String> info = new HashMap<>();
        info.put("os", System.getProperty("os.name"));
        info.put("os_version", System.getProperty("os.version"));
        info.put("java_version", System.getProperty("java.version"));
        info.put("locale", java.util.Locale.getDefault().toString());
        return info;
    }
}

// Usage Example
// FeedbackPulse client = new FeedbackPulse(
//     "fp_your_api_key_here",
//     "2.1.0",
//     "desktop",
//     "production"
// );
//
// FeedbackPulse.FeedbackResult result = client.submit(
//     "positive",
//     "Java integration works great!",
//     "main_screen"
// );
//
// if (result.success()) {
//     System.out.println("Feedback submitted: " + result.feedbackId());
// } else {
//     System.err.println("Error: " + result.error());
// }
