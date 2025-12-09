defmodule Amplitude.API.Real do
  alias HTTPoison
  alias HTTPoison.{Response, Error}

  defp api_host, do: Application.get_env(:amplitude, :api_host)
  defp api_key, do: Application.get_env(:amplitude, :api_key)
  defp json_header, do: [{"Content-Type", "application/json"}]

  def api_track(params) do
    url = api_host()

    query =
      URI.encode_query(%{
        api_key: api_key(),
        event: Poison.encode!(params)
      })

    case HTTPoison.get("#{url}?#{query}", json_header()) do
      {:ok, %Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:ok, %Response{status_code: 404, body: body}} ->
        {:error, body}

      {:ok, %Response{status_code: code, body: body}} ->
        {:error, "Unexpected status code #{code}: #{body}"}

      {:error, %Error{reason: reason}} ->
        {:error, reason}
    end
  end

  # validate Poison response and strip out json value
  def verify_json({:ok, json}), do: json
  def verify_json({_, response}), do: "#{inspect(response)}"
end
