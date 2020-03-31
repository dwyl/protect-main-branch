defmodule Protect.Mixfile do
  use Mix.Project

  def project do
    [
      app: :protect,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps(),
      escript: [main_module: Protect],
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
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
      {:credo, "~> 1.3.2", only: [:dev, :test], runtime: false},
      {:pre_commit, "~> 0.3.4", only: :dev},
      {:excoveralls, "~> 0.12.3", only: [:dev, :test]}
    ]
  end
end
