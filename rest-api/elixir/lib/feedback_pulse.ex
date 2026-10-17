defmodule FeedbackPulse do
  @moduledoc """
  Client for the F-Pulse App API.
  """

  @base_url "https://api.fpulse.app/v1"

  defstruct [:api_key, :app_version, :app_type, :environment]

  @type t :: %__MODULE__{
    api_key: String.t(),
    app_version: String.t(),
    app_type: String.t(),
    environment: String.t()
  }

  @type feedback_result :: {:ok, map()} | {:error, String.t()}

  @doc """
  Creates a new FeedbackPulse client.
  """
  @spec new(String.t(), String.t(), keyword()) :: t()
  def new(api_key, app_version, opts \\ []) do
    %__MODULE__{
      api_key: api_key,
      app_version: app_version,
      app_type: Keyword.get(opts, :app_type, "web"),
      environment: Keyword.get(opts, :environment, "production")
    }
  end

  @doc """
  Submits feedback to the API.
  """
  @spec submit(t(), String.t(), keyword()) :: feedback_result()
  def submit(%__MODULE__{} = client, sentiment, opts \\ []) do
    body = %{
      sentiment: sentiment,
      app_version: client.app_version,
      app_type: client.app_type,
      environment: client.environment,
      device_info: get_device_info()
    }
    |> maybe_put(:comment, Keyword.get(opts, :comment))
    |> maybe_put(:screen_id, Keyword.get(opts, :screen_id))
    |> maybe_put(:user_identifier, Keyword.get(opts, :user_identifier))
    |> maybe_put(:metadata, Keyword.get(opts, :metadata))

    headers = [
      {"Content-Type", "application/json"},
      {"X-API-Key", client.api_key}
    ]

    case HTTPoison.post("#{@base_url}/feedback", Jason.encode!(body), headers) do
      {:ok, %HTTPoison.Response{status_code: 201, body: body}} ->
        {:ok, Jason.decode!(body)}

      {:ok, %HTTPoison.Response{body: body}} ->
        case Jason.decode(body) do
          {:ok, %{"error" => error}} -> {:error, error}
          _ -> {:error, "Unknown error"}
        end

      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, to_string(reason)}
    end
  end

  defp get_device_info do
    %{
      os: to_string(:os.type() |> elem(0)),
      os_version: :erlang.system_info(:otp_release) |> to_string(),
      elixir_version: System.version(),
      locale: System.get_env("LANG", "en_US")
    }
  end

  defp maybe_put(map, _key, nil), do: map
  defp maybe_put(map, key, value), do: Map.put(map, key, value)
end

# Usage Example
# client = FeedbackPulse.new(
#   "fp_your_api_key_here",
#   "2.1.0",
#   app_type: "web",
#   environment: "production"
# )
#
# case FeedbackPulse.submit(client, "positive",
#   comment: "Elixir is elegant!",
#   screen_id: "home",
#   user_identifier: "user@example.com"
# ) do
#   {:ok, %{"feedback_id" => id}} ->
#     IO.puts("Feedback submitted: #{id}")
#
#   {:error, reason} ->
#     IO.puts("Error: #{reason}")
# end
