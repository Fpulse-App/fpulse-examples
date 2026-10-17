// Program.cs
builder.Services.AddSingleton(sp =>
    new FeedbackPulseClient(
        apiKey: builder.Configuration["FeedbackPulse:ApiKey"]!,
        appVersion: Assembly.GetExecutingAssembly().GetName().Version?.ToString() ?? "1.0.0",
        appType: "web",
        environment: builder.Environment.EnvironmentName.ToLower()
    ));

// In a Controller
[ApiController]
[Route("api/[controller]")]
public class FeedbackController : ControllerBase
{
    private readonly FeedbackPulseClient _feedbackClient;

    public FeedbackController(FeedbackPulseClient feedbackClient)
        => _feedbackClient = feedbackClient;

    [HttpPost]
    public async Task<IActionResult> Submit([FromBody] FeedbackDto dto)
    {
        var result = await _feedbackClient.SubmitAsync(
            sentiment: dto.Sentiment,
            comment: dto.Comment,
            screenId: Request.Path,
            userIdentifier: User.Identity?.Name
        );

        return result.Success
            ? Ok(new { id = result.FeedbackId })
            : BadRequest(new { error = result.Error });
    }
}
