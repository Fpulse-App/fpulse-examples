# config/initializers/feedback_pulse.rb
FEEDBACK_PULSE = FeedbackPulse.new(
  api_key: Rails.application.credentials.fpulse_api_key,
  app_version: Rails.application.config.version,
  environment: Rails.env
)

# In a controller
class FeedbackController < ApplicationController
  def create
    result = FEEDBACK_PULSE.submit(
      sentiment: params[:sentiment],
      comment: params[:comment],
      screen_id: request.path,
      user_identifier: current_user&.email
    )

    if result.success
      render json: { success: true, id: result.feedback_id }
    else
      render json: { success: false, error: result.error }, status: :unprocessable_entity
    end
  end
end
