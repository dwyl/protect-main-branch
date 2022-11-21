import Mix.Config

config :pre_commit,
  commands: ["test", "credo --strict"],
  verbose: true
