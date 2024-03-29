defmodule Protect do
  @moduledoc """
    Functions that turn into a command line script that takes an owner,
    and a json file of protection rules, and applies those rules to the
    main branch of all the organization's repos
  """
  require Logger
  require Poison
  alias Protect.Github

  @doc """
    The function that is called when the command line script is run.
    The arguments are passed in from the command line options.
  """
  def main(args) do
    options = args |> parse_args |> validate_options

    rules = options[:rules] |> File.read!()

    options
    |> get_repos
    |> Enum.map(fn repo ->
      rename_master_to_main(options, repo)

      options
      |> protect_repo(repo, rules)
      |> Map.put(:repo_name, repo)
    end)
    |> report
  end

  @doc """
    Parses command line arguments into a keyword list.
  """
  def parse_args(args) do
    {options, _, _} =
      OptionParser.parse(args,
        switches: [org: :string, rules: :string, user: :string]
      )

    options
  end

  @doc """
    Checks if the command line options are valid, and throws an error if not.
  """
  def validate_options(options) do
    if options[:org] && options[:user] do
      raise "You can only protect repos for one organisation or user at a time"
    end

    if !options[:org] && !options[:user] do
      raise "You must provide an organisation or user"
    end

    if !options[:rules] do
      raise "You must provide a json file of protection rules"
    end

    if !Regex.match?(~r/.+\.json$/, options[:rules]) do
      raise "--rules must be a json file"
    end

    Enum.each(
      [options[:org], options[:user]],
      &if &1 && Regex.match?(~r/[^a-zA-Z0-9\-]/, &1) do
        raise "user/org must be a valid Github username"
      end
    )

    options
  end

  @doc """
    Gets a list of Github repos for an owner that can be either a user or an
    organization.
  """
  def get_repos(options, page \\ 1, repos \\ []) do
    new_repos =
      options
      |> get_repos_url(page)
      |> Github.get!()
      |> Map.get(:body, "{}")
      |> Poison.decode!()
      |> Enum.map(&Map.fetch!(&1, "name"))

    case length(new_repos) < 100 do
      true -> repos ++ new_repos
      _ -> get_repos(options, page + 1, repos ++ new_repos)
    end
  end

  defp owner(options), do: options[:org] || options[:user]

  @doc """
    Determines the correct url to use in the get_repos function, depending on
    whether the repo owner is a user or an organization.
  """
  def get_repos_url(options, page \\ 1) do
    cond do
      options[:org] ->
        "/orgs/#{owner(options)}/repos?per_page=100&page=#{page}"

      options[:user] ->
        "/users/#{owner(options)}/repos?per_page=100&page=#{page}"
    end
  end

  @doc """
    `rename_master_to_main/2` renames the given repo's default branch from master to main.
    should fail silently.
    API Doc: https://docs.github.com/en/rest/branches/branches#rename-a-branch
    Ref: https://openssl.medium.com/renaming-the-default-branch-from-master-to-main-on-github-2f965cdbbc19
  """
  def rename_master_to_main(options, repo) do
    "/repos/#{owner(options)}/#{repo}/branches/master/rename"
    |> Github.post!(Poison.encode!(%{new_name: "main"}))
    |> dbg()
  end

  @doc """
    Applies a set of rules to the main branch of the repo specified.
  """
  def protect_repo(options, repo, rules) do
    owner = options[:org] || options[:user]

    "/repos/#{owner}/#{repo}/branches/main/protection"
    |> Github.put!(rules)
    |> dbg()
  end

  @doc """
    Reports how many repos were successfully or unsuccessfully protected.
  """
  def report(results) do
    fail = Enum.filter(results, fn res -> res.status_code != 200 end)
    fail_count = Enum.count(fail)
    success_count = Enum.count(results, fn res -> res.status_code == 200 end)

    Enum.each(fail, &IO.puts("Error #{&1.status_code}: #{&1.repo_name}"))

    IO.puts("""
      #{success_count} branches successfully protected
      #{fail_count} branches errored
    """)
  end
end
