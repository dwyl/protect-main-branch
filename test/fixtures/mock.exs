defmodule Protect.Mock.HTTPoison do
  def request!("get", _url, _body, _headers) do
    %{body: "[{\"name\": \"test\"}]"}
  end
  def request!("put", _url, _body, _headers) do
    %{status_code: 200}
  end
end
