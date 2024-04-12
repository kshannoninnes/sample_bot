defmodule Bot.Core.Main do
  use Application

  # Entry Point
  def start(_type, _args) do
    children = [
      Nosedrum.Storage.Dispatcher,
      Bot.Core.Consumer
    ]

    options = [strategy: :one_for_one, name: Bot.Supervisor]
    Supervisor.start_link(children, options)
  end
end

defmodule Bot.Core.Consumer do
  use Nostrum.Consumer

  alias Bot.Core.CommandHandler

  def handle_event({:READY, _, _}), do: CommandHandler.register_commands()
  def handle_event({:INTERACTION_CREATE, intr, _}), do: CommandHandler.handle_command(intr)
  def handle_event(_), do: :ok
end
