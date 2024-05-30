defmodule Bot.Core.ApplicationCommandLoader do
  require Logger

  alias Nosedrum.Storage.Dispatcher

  def load_all() do
    get_all_command_modules()
    |> filter_application_commands()
    |> queue_commands()

    register_commands()
  end

  defp get_all_command_modules() do
    # See: https://www.erlang.org/doc/man/code#all_available-0
    :code.all_available()
    |> Enum.filter(fn {module, _, _} -> is_command?(module) end)
    |> Enum.map(fn {module_charlist, _, _} -> List.to_existing_atom(module_charlist) end)
  end

  defp is_command?(module_charlist) do
    List.to_string(module_charlist)
    |> String.starts_with?("Elixir.Bot.Commands")
  end

  # Filter out any module that doesn't implement the ApplicationCommand behaviour
  defp filter_application_commands(command_list) do
    Enum.filter(command_list, fn command ->
      case command.module_info(:attributes)[:behaviour] do
        attr when is_list(attr) -> Enum.member?(attr, Nosedrum.ApplicationCommand)

        # Skip because module doesn't implement ANY behaviour
        nil -> false
      end
    end)
  end

  defp queue_commands(commands) do
    Enum.each(commands, fn command ->
      Dispatcher.queue_command(command.name, command)
      Logger.debug("Added module #{command} as command /#{command.name}")
    end)
  end

  defp register_commands() do
    Application.get_env(:bot, :guild_ids)
    |> Enum.each(fn server_id ->
      case Dispatcher.process_queue(server_id) do
        {:error, {:error, error}} ->
          Logger.error(
            "Error processing commands for server #{server_id}:\n #{inspect(error, pretty: true)}"
          )

        _ ->
          Logger.debug("Successfully registered application commands to #{server_id}")
      end
    end)
  end
end
