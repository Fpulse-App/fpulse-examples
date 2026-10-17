import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import reactor.core.publisher.Mono;

@Service
public class FeedbackService {
    private final WebClient webClient;
    private final String appVersion;

    public FeedbackService(
        @Value("${fpulse.api-key}") String apiKey,
        @Value("${fpulse.app-version:1.0.0}") String appVersion
    ) {
        this.appVersion = appVersion;
        this.webClient = WebClient.builder()
            .baseUrl("https://api.fpulse.app/v1")
            .defaultHeader("X-API-Key", apiKey)
            .defaultHeader("Content-Type", "application/json")
            .build();
    }

    public Mono<FeedbackResult> submit(String sentiment, String comment, String screenId) {
        var body = Map.of(
            "sentiment", sentiment,
            "comment", comment != null ? comment : "",
            "screen_id", screenId,
            "app_version", appVersion,
            "app_type", "web",
            "environment", "production"
        );

        return webClient.post()
            .uri("/feedback")
            .bodyValue(body)
            .retrieve()
            .bodyToMono(FeedbackResult.class);
    }

    public record FeedbackResult(boolean success, Integer feedbackId, String error) {}
}
