use Mix.Config

config :protect,
  httpoison: HTTPoison

import_config "#{Mix.env}.exs"
