// In a Controller or Service
use Illuminate\Support\Facades\Http;

class FeedbackService
{
    public function submit(string $sentiment, ?string $comment = null): array
    {
        $response = Http::withHeaders([
            'X-API-Key' => config('services.fpulse.api_key'),
        ])->post('https://api.fpulse.app/v1/feedback', [
            'sentiment' => $sentiment,
            'comment' => $comment,
            'app_version' => config('app.version'),
            'app_type' => 'web',
            'screen_id' => request()->path(),
            'user_identifier' => auth()->user()?->email,
            'environment' => app()->environment(),
        ]);

        return $response->json();
    }
}
