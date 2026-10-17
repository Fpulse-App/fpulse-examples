<?php

declare(strict_types=1);

readonly class FeedbackResult
{
    public function __construct(
        public bool $success,
        public ?int $feedbackId = null,
        public ?string $error = null
    ) {}
}

class FeedbackPulse
{
    private const BASE_URL = 'https://api.fpulse.app/v1';

    public function __construct(
        private string $apiKey,
        private string $appVersion = '1.0.0',
        private string $appType = 'web',
        private string $environment = 'production'
    ) {}

    public function submit(
        string $sentiment,
        ?string $comment = null,
        ?string $screenId = null,
        ?string $userIdentifier = null,
        ?array $metadata = null
    ): FeedbackResult {
        $payload = [
            'sentiment' => $sentiment,
            'app_version' => $this->appVersion,
            'app_type' => $this->appType,
            'environment' => $this->environment,
            'device_info' => [
                'os' => PHP_OS_FAMILY,
                'os_version' => php_uname('r'),
                'locale' => locale_get_default() ?: 'en_US',
            ],
        ];

        if ($comment !== null) $payload['comment'] = $comment;
        if ($screenId !== null) $payload['screen_id'] = $screenId;
        if ($userIdentifier !== null) $payload['user_identifier'] = $userIdentifier;
        if ($metadata !== null) $payload['metadata'] = $metadata;

        try {
            $response = $this->request('POST', '/feedback', $payload);

            return new FeedbackResult(
                success: $response['success'] ?? false,
                feedbackId: $response['feedback_id'] ?? null,
                error: $response['error'] ?? null
            );
        } catch (Exception $e) {
            return new FeedbackResult(success: false, error: $e->getMessage());
        }
    }

    public function submitBatch(array $feedbacks): array
    {
        return $this->request('POST', '/feedback/batch', ['feedbacks' => $feedbacks]);
    }

    private function request(string $method, string $endpoint, array $data): array
    {
        $ch = curl_init(self::BASE_URL . $endpoint);

        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_HTTPHEADER => [
                'Content-Type: application/json',
                'X-API-Key: ' . $this->apiKey,
            ],
            CURLOPT_CUSTOMREQUEST => $method,
            CURLOPT_POSTFIELDS => json_encode($data),
            CURLOPT_TIMEOUT => 30,
        ]);

        $response = curl_exec($ch);
        $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
        if (PHP_VERSION_ID < 80000) {
            curl_close($ch); // No effect (and deprecated) since PHP 8
        }

        if ($response === false) {
            throw new Exception('Request failed');
        }

        return json_decode($response, true) ?? [];
    }
}

// Usage Example
$client = new FeedbackPulse(
    apiKey: 'fp_your_api_key_here',
    appVersion: '2.1.0',
    appType: 'web'
);

$result = $client->submit(
    sentiment: 'positive',
    comment: 'The checkout process is so smooth!',
    screenId: 'checkout',
    userIdentifier: 'user@example.com',
    metadata: ['cart_total' => 99.99]
);

if ($result->success) {
    echo "Feedback submitted! ID: {$result->feedbackId}\n";
} else {
    echo "Error: {$result->error}\n";
}
