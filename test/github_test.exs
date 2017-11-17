defmodule ProtectTest.Github do
  use ExUnit.Case
  alias Protect
  alias Protect.Github

  describe "get!/1" do
    test "get" do
      assert Github.get!("/users/danwhy/repos?per_page=100&page=1") ==
        %{body: "[{\"name\": \"test\"}]"}
    end
  end

  describe "put!/2" do
    test "put" do
      assert Github.put!(
        "/repos/danwhy/test/branches/master/protection", %{test: "body"}
      ) == %{status_code: 200}
    end
  end
end
