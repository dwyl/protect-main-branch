defmodule Protect.Github do
  @moduledoc """
    Helper functions to interact with the Github API.
  """
  @httpoison Application.get_env :protect, :httpoison
  @auth_token System.get_env "GITHUB_ACCESS_TOKEN"
  @root_url "https://api.github.com"

  def get!(url), do: request! "get", url
  def put!(url, body), do: request! "put", url, body

  defp request!(method, url, body \\ "") do
    headers = [{"Authorization", "token #{@auth_token}"}]

    method |> @httpoison.request!(@root_url <> url, body, headers)
  end
end
