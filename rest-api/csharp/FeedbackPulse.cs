using System.Net.Http.Json;
using System.Text.Json.Serialization;

namespace FeedbackPulse;

public record FeedbackResult(
    [property: JsonPropertyName("success")] bool Success,
    [property: JsonPropertyName("feedback_id")] int? FeedbackId = null,
    [property: JsonPropertyName("error")] string? Error = null
);

public class FeedbackRequest
{
    [JsonPropertyName("sentiment")] public required string Sentiment { get; init; }
    [JsonPropertyName("comment")] public string? Comment { get; init; }
    [JsonPropertyName("app_version")] public required string AppVersion { get; init; }
    [JsonPropertyName("app_type")] public required string AppType { get; init; }
    [JsonPropertyName("screen_id")] public string? ScreenId { get; init; }
    [JsonPropertyName("user_identifier")] public string? UserIdentifier { get; init; }
    [JsonPropertyName("environment")] public string Environment { get; init; } = "production";
    [JsonPropertyName("device_info")] public Dictionary<string, string>? DeviceInfo { get; init; }
    [JsonPropertyName("metadata")] public Dictionary<string, object>? Metadata { get; init; }
}

public class FeedbackPulseClient : IDisposable
{
    private const string BaseUrl = "https://api.fpulse.app/v1";
    private readonly HttpClient _httpClient;
    private readonly string _appVersion;
    private readonly string _appType;
    private readonly string _environment;

    public FeedbackPulseClient(
        string apiKey,
        string appVersion,
        string appType = "desktop",
        string environment = "production")
    {
        _appVersion = appVersion;
        _appType = appType;
        _environment = environment;

        _httpClient = new HttpClient
        {
            BaseAddress = new Uri(BaseUrl),
            Timeout = TimeSpan.FromSeconds(30)
        };
        _httpClient.DefaultRequestHeaders.Add("X-API-Key", apiKey);
    }

    public async Task<FeedbackResult> SubmitAsync(
        string sentiment,
        string? comment = null,
        string? screenId = null,
        string? userIdentifier = null,
        Dictionary<string, object>? metadata = null,
        CancellationToken ct = default)
    {
        var request = new FeedbackRequest
        {
            Sentiment = sentiment,
            Comment = comment,
            AppVersion = _appVersion,
            AppType = _appType,
            ScreenId = screenId,
            UserIdentifier = userIdentifier,
            Environment = _environment,
            Metadata = metadata,
            DeviceInfo = new Dictionary<string, string>
            {
                ["os"] = Environment.OSVersion.Platform.ToString(),
                ["os_version"] = Environment.OSVersion.VersionString,
                ["runtime"] = Environment.Version.ToString()
            }
        };

        try
        {
            var response = await _httpClient.PostAsJsonAsync("/feedback", request, ct);
            return await response.Content.ReadFromJsonAsync<FeedbackResult>(ct)
                   ?? new FeedbackResult(false, Error: "Failed to parse response");
        }
        catch (Exception ex)
        {
            return new FeedbackResult(false, Error: ex.Message);
        }
    }

    public void Dispose() => _httpClient.Dispose();
}

// Usage Example
// var client = new FeedbackPulseClient(
//     apiKey: "fp_your_api_key_here",
//     appVersion: "2.1.0",
//     appType: "desktop"
// );
//
// var result = await client.SubmitAsync(
//     sentiment: "positive",
//     comment: ".NET is awesome!",
//     screenId: "main_window"
// );
//
// if (result.Success)
//     Console.WriteLine($"Feedback submitted! ID: {result.FeedbackId}");
// else
//     Console.WriteLine($"Error: {result.Error}");
