# config/config.exs
config :my_app, :feedback_pulse,
  api_key: System.get_env("FPULSE_API_KEY"),
  app_version: Mix.Project.config()[:version]

# lib/my_app/feedback.ex
defmodule MyApp.Feedback do
  @config Application.compile_env(:my_app, :feedback_pulse)

  def client do
    FeedbackPulse.new(
      @config[:api_key],
      @config[:app_version],
      app_type: "web",
      environment: Mix.env() |> to_string()
    )
  end

  def submit(sentiment, opts \\ []) do
    FeedbackPulse.submit(client(), sentiment, opts)
  end
end

# In a Phoenix Controller
defmodule MyAppWeb.FeedbackController do
  use MyAppWeb, :controller

  def create(conn, %{"sentiment" => sentiment, "comment" => comment}) do
    case MyApp.Feedback.submit(sentiment,
      comment: comment,
      screen_id: conn.request_path,
      user_identifier: get_session(conn, :user_email)
    ) do
      {:ok, %{"feedback_id" => id}} ->
        json(conn, %{success: true, id: id})

      {:error, reason} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{success: false, error: reason})
    end
  end
end
