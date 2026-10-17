require 'net/http'
require 'json'
require 'uri'

class FeedbackPulse
  BASE_URL = 'https://api.fpulse.app/v1'.freeze

  FeedbackResult = Struct.new(:success, :feedback_id, :error, keyword_init: true)

  def initialize(api_key:, app_version: '1.0.0', app_type: 'web', environment: 'production')
    @api_key = api_key
    @app_version = app_version
    @app_type = app_type
    @environment = environment
  end

  def submit(sentiment:, comment: nil, screen_id: nil, user_identifier: nil, metadata: nil)
    payload = {
      sentiment: sentiment,
      app_version: @app_version,
      app_type: @app_type,
      environment: @environment,
      device_info: device_info
    }

    payload[:comment] = comment if comment
    payload[:screen_id] = screen_id if screen_id
    payload[:user_identifier] = user_identifier if user_identifier
    payload[:metadata] = metadata if metadata

    response = request(:post, '/feedback', payload)

    FeedbackResult.new(
      success: response['success'],
      feedback_id: response['feedback_id'],
      error: response['error']
    )
  rescue StandardError => e
    FeedbackResult.new(success: false, error: e.message)
  end

  def submit_batch(feedbacks)
    request(:post, '/feedback/batch', { feedbacks: feedbacks })
  end

  private

  def device_info
    {
      os: RUBY_PLATFORM,
      os_version: RUBY_VERSION,
      locale: ENV['LANG'] || 'en_US'
    }
  end

  def request(method, endpoint, body)
    uri = URI("#{BASE_URL}#{endpoint}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = uri.scheme == 'https'

    request = case method
              when :post then Net::HTTP::Post.new(uri)
              when :get then Net::HTTP::Get.new(uri)
              end

    request['Content-Type'] = 'application/json'
    request['X-API-Key'] = @api_key
    request.body = body.to_json

    response = http.request(request)
    JSON.parse(response.body)
  end
end

# Usage Example
client = FeedbackPulse.new(
  api_key: 'fp_your_api_key_here',
  app_version: '2.1.0',
  app_type: 'web'
)

result = client.submit(
  sentiment: 'positive',
  comment: 'Ruby rocks!',
  screen_id: 'dashboard',
  user_identifier: 'user@example.com'
)

if result.success
  puts "Feedback submitted! ID: #{result.feedback_id}"
else
  puts "Error: #{result.error}"
end
