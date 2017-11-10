defmodule Protect.Github do
  require HTTPoison

  @auth_token System.get_env "GITHUB_ACCESS_TOKEN"
  @root_url "https://api.github.com"

  def get!(url), do: request! "get", url
  def put!(url, body), do: request! "put", url, body

  defp request!(method, url, body \\ "") do
    headers = [{"Authorization", "token #{@auth_token}"}]

    method |> HTTPoison.request!(@root_url <> url, body, headers)
  end
end
