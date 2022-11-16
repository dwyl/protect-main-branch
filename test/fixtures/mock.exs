defmodule Protect.Mock.HTTPoison do
  def request!("get", url, _body, _headers) do
    case url =~ "orgs" and url =~ "&page=1" do
      true ->
        {:ok, cwd} = File.cwd
        %{body: File.read!(cwd <> "/test/fixtures/repos.json")}
      _ -> %{body: "[{\"name\": \"test\"}]"}
    end
  end
  def request!("put", _url, _body, _headers) do
    %{status_code: 200}
  end
  def request!("patch", _url, _body, _headers) do
    %{status_code: 200}
  end
end
