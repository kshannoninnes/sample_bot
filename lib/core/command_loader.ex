defmodule Bot.Core.CommandLoader do
  require Logger

  alias Nosedrum.Storage.Dispatcher

  # Any module that implements Nosedrum.ApplicationCommand will be picked up
  # and registered as a command via Nosedrum.Storage.Dispatcher
  def load_application_commands() do
    cmd_dir = "lib/commands"
    Logger.debug("Loading application command files from #{cmd_dir}")

    command_modules =
      get_command_files(cmd_dir)
      |> filter_application_commands()
      |> get_command_modules()

    case command_modules do
      [] ->
        Logger.info("No application commands loaded")

      command_modules ->
        queue_application_commands(command_modules)
        register_application_commands()
        Logger.info("Application commands loaded")
    end
  end

  defp get_command_files(cmd_dir) do
    Path.absname(cmd_dir)
    |> Xfile.ls!(recursive: true, filter: &String.ends_with?(&1, ".ex"))
    |> Enum.to_list()
  end

  defp filter_application_commands(file_list) do
    Enum.reduce(file_list, [], fn file, acc ->
      pattern = ~r{defmodule \s+ ([^\s]+) (.|\n)* @behaviour\sNosedrum\.ApplicationCommand}x
      contents = File.read!(file)

      case Regex.run(pattern, contents, capture: :all_but_first) do
        nil ->
          Logger.debug("No command files found implementing Nosedrum.ApplicationCommand")
          acc

        match ->
          module_name = List.flatten(match) |> List.first()
          [module_name | acc]
      end
    end)
  end

  defp get_command_modules(file_list) do
    Enum.map(file_list, fn name ->
      Logger.debug("Converting string '#{name}' to module")
      String.to_existing_atom("Elixir." <> name)
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
