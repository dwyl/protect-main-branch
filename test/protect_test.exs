defmodule ProtectTest do
  use ExUnit.Case
  import ExUnit.CaptureIO

  @invalid_options [
    [],
    [org: "dwyl", user: "danwhy"],
    [org: "dwyl"],
    [org: "danwhy"],
    [rules: "./fixtures/test.json"],
    [user: "danwhy", rules: "./test.txt"],
    [user: "???", rules: "./fixtures/test.json"]
  ]

  @valid_options [
    [user: "nelsonic", rules: "./fixtures/test.json"],
    [org: "dwyl", rules: "./fixtures/test.json"]
  ]

  describe "validate_options/1" do
    test "invalid options" do
      Enum.each(
        @invalid_options,
        &(assert_raise(RuntimeError, fn -> Protect.validate_options(&1) end))
      )
    end

    test "valid options" do
      Enum.each(@valid_options, &(assert(Protect.validate_options(&1) == &1)))
    end
  end

  describe "get_repos_url" do
    test "get user repos" do
      assert Protect.get_repos_url([user: "danwhy"]) ==
        "/users/danwhy/repos?per_page=100&page=1"
    end

    test "get org repos" do
      assert Protect.get_repos_url([org: "dwyl"]) ==
        "/orgs/dwyl/repos?per_page=100&page=1"
    end

    test "get second page" do
      assert Protect.get_repos_url([org: "dwyl"], 2) ==
        "/orgs/dwyl/repos?per_page=100&page=2"
    end
  end

  describe "report/1" do
    # Tuples representing: {list of status codes, successes, failures}
    @status_200 %{status_code: 200, repo_name: "test"}
    @status_404 %{status_code: 404, repo_name: "test"}
    @status_500 %{status_code: 500, repo_name: "test"}

    @status_codes [
      {[@status_200, @status_200, @status_200, @status_200], 4, 0},
      {[@status_404, @status_404, @status_200, @status_404], 1, 3},
      {[@status_500, @status_500], 0, 2},
      {[@status_500, @status_200, @status_500, @status_200], 2, 2},
      {[@status_404], 0, 1}
    ]

    test "report" do
      Enum.each(
        @status_codes,
        fn {status, success, fail} ->
          assert capture_io(fn -> Protect.report(status) end) =~ """
            #{success} branches succesfully protected
            #{fail} branches errored
          """
        end
      )
    end
  end

  describe "get_repos/3" do
    test "get repos user" do
      assert Protect.get_repos([user: "danwhy"]) == ["test"]
    end

    test "get repos org" do
      url = "https://api.github.com/orgs/dwyl/repos?per_page=100&page=1"
      repos = Protect.Mock.HTTPoison.request!("get", url, "_body", "_headers")
      |> Map.get(:body, "{}")
      |> Poison.decode!
      |> Enum.map(&Map.fetch!(&1, "name"))

      assert Protect.get_repos([org: "dwyl"]) == repos ++["test"]
    end
  end

  describe "protect_repo/3" do
    test "protect repo" do
      assert Protect.protect_repo(
        [user: "danwhy"],
        "/repos/danwhy/test/branches/master/protection",
        %{test: "body"}
      ) == %{status_code: 200}
    end
  end

  describe "main/1" do
    test "main success" do
      assert Protect.main(
        ["--user", "danwhy", "--rules", "./test/fixtures/test.json"]
      ) == :ok

      assert capture_io(
        fn ->
          ["--user", "danwhy", "--rules", "./test/fixtures/test.json"]
          |> Protect.main
        end) =~ """
          1 branches succesfully protected
          0 branches errored
        """
    end

    test "main bad arguments" do
      Enum.each(
        @invalid_options,
        &(assert_raise(RuntimeError, fn -> Protect.main(&1) end))
      )
    end
  end
end
