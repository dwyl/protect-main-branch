defmodule Protect do
  @moduledoc """
    Functions that turn into a command line script that takes an organisation
    name and a json file of protection rules, and applies those rules to the
    master branch of all the organisation's repos
  """
  require Poison
  alias Protect.Github


  def main(args) do
    options = args |> parse_args

    rules = options[:rules] |> File.read!

    get_repos(options[:org])
    |> Enum.map(fn repo ->
      protect_repo(options[:org], repo, rules)
      |> Map.get(:status_code)
    end)
    |> report
  end


  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [org: :string, rules: :string]
    )
    options
  end


  def get_repos(org, page \\ 1, repos \\ []) do
    new_repos = "/users/#{org}/repos?per_page=100&page=#{page}"
    |> Github.get!
    |> Map.get(:body, "{}")
    |> Poison.decode!
    |> Enum.map(&Map.fetch!(&1, "name"))

    case length(new_repos) < 100 do
      true -> repos ++ new_repos
      _ -> get_repos org, page + 1, repos ++ new_repos
    end
  end


  def protect_repo(org, repo, rules) do
    "/repos/#{org}/#{repo}/branches/master/protection"
    |> Github.put!(rules)
  end


  def report(results) do
    success = Enum.count(results, fn res -> res == 200 end)
    fail = Enum.count(results, fn res -> res != 200 end)
    IO.puts """
      #{success} branches succesfully protected
      #{fail} branches errored
    """
  end
end
