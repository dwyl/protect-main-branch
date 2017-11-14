defmodule ProtectTest do
  use ExUnit.Case
  doctest Protect
  alias Protect
  import ExUnit.CaptureIO

  describe "validate_options/1" do
    @invalid_options [
      [],
      [org: "dwyl", user: "danwhy"],
      [org: "dwyl"],
      [org: "danwhy"],
      [rules: "./test.json"],
      [user: "danwhy", rules: "./test.txt"]
    ]

    @valid_options [
      [user: "danwhy", rules: "./test.json"],
      [org: "dwyl", rules: "./test.json"]
    ]

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
    @status_codes [
      {[200, 200, 200, 200], 4, 0},
      {[404, 404, 200, 404], 1, 3},
      {[500, 500], 0, 2},
      {[500, 200, 500, 200], 2, 2},
      {[404], 0, 1}
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
end
