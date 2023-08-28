defmodule Protect.Mixfile do
  use Mix.Project

  def project do
    [
      app: :protect,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      escript: [main_module: Protect],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        c: :test,
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
        "coveralls.post": :test,
        t: :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 4.0.1"},
      {:httpoison, "~> 1.6.2"},

      # Environment Variables: github.com/dwyl/envar
      {:envar, "~> 1.0.9"},

      # Code format: github.com/rrrene/credo
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      {:pre_commit, "~> 0.3.4", only: :dev},
      # Check test coverage: github.com/parroty/excoveralls
      {:excoveralls, "~> 0.17.1", only: :test}
    ]
  end

  defp aliases do
    [
      c: ["coveralls.html"],
      t: ["test"]
    ]
  end
end
