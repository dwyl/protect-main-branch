defmodule Protect do
  @moduledoc """
    Functions that turn into a command line script that takes an organisation
    name and a json file of protection rules, and applies those rules to the
    master branch of all the organisation's repos
  """
  require Poison
  alias Protect.Github


  def main(args) do
    options = args |> parse_args |> validate_options

    rules = options[:rules] |> File.read!

    options
    |> get_repos
    |> Enum.map(fn repo ->
      options
      |> protect_repo(repo, rules)
      |> Map.get(:status_code)
    end)
    |> report
  end


  defp parse_args(args) do
    {options, _, _} = OptionParser.parse(args,
      switches: [org: :string, rules: :string, user: :string]
    )
    options
  end


  defp validate_options(options) do
    if options[:org] && options[:user] do
      raise "You can only protect repos for one organisation or user at a time"
    end

    if !options[:org] && !options[:user] do
      raise "You must provide an organisation or user"
    end

    if !options[:rules] do
      raise "You must provide a json file of protection rules"
    end

    options
  end


  def get_repos(options, page \\ 1, repos \\ []) do
    new_repos =
      options
      |> get_repos_url(page)
      |> Github.get!
      |> Map.get(:body, "{}")
      |> Poison.decode!
      |> Enum.map(&Map.fetch!(&1, "name"))

    case length(new_repos) < 100 do
      true -> repos ++ new_repos
      _ -> get_repos options, page + 1, repos ++ new_repos
    end
  end


  def get_repos_url(options, page \\ 1) do
      cond do
        options[:org] ->
          "/orgs/#{options[:org]}/repos?per_page=100&page=#{page}"
        options[:user] ->
          "/users/#{options[:user]}/repos?per_page=100&page=#{page}"
      end
  end


  def protect_repo(options, repo, rules) do
    owner = options[:org] || options[:user]

    "/repos/#{owner}/#{repo}/branches/master/protection"
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
