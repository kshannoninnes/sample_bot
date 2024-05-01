defmodule Bot.Core.ApplicationCommandLoader do
  require Logger

  alias Nosedrum.Storage.Dispatcher

  # Any module that implements Nosedrum.ApplicationCommand will be picked up
  # and registered as a command via Nosedrum.Storage.Dispatcher
  def load_application_commands() do
    get_command_modules()
    |> filter_application_commands()
    |> queue_application_commands()

    register_application_commands()
  end

  defp get_command_modules() do
    # See: https://www.erlang.org/doc/man/code#all_available-0
    :code.all_available()
    |> Enum.filter(fn {module, _, _} -> is_command?(module) end)
    |> Enum.map(fn {module, _, _} -> List.to_existing_atom(module) end)
  end

  defp is_command?(module_charlist) do
    List.to_string(module_charlist) |> String.starts_with?("Elixir.Bot.Commands")
  end

  defp filter_application_commands(command_list) do
    Enum.filter(command_list, fn command ->
      command.module_info(:attributes)[:behaviour]
      |> Enum.member?(Nosedrum.ApplicationCommand)
    end)
  end

  defp queue_application_commands(commands) do
    Enum.each(commands, fn command ->
      Dispatcher.queue_command(command.name, command)
      Logger.debug("Added module #{command} as command /#{command.name}")
    end)
  end

  defp register_application_commands() do
    Application.get_env(:bot, :guild_ids)
    |> Enum.each(fn server_id ->
      Dispatcher.process_queue(server_id)
      Logger.debug("Successfully registered application commands to #{server_id}")
    end)
  end
end
