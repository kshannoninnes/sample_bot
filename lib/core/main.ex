defmodule Bot.Core.Main do
  use Application

  # Entry Point of the program, defined by application/1 in mix.exs
  def start(_type, _args) do
    children = [
      Nosedrum.Storage.Dispatcher,
      Bot.Core.CommandHandler
    ]

    options = [strategy: :one_for_one, name: Bot.Supervisor]
    Supervisor.start_link(children, options)
  end
end
