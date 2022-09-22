defmodule Bot.Commands.General.Ping do
  require Logger
  @behaviour Nosedrum.ApplicationCommand

  def name(), do: "ping"

  @impl true
  def description(), do: "Ping the bot to check for lifesigns."

  @impl true
  def command(_interaction), do: [content: "pong!"]

  @impl true
  def type(), do: :slash
end
