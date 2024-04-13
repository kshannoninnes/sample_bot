defmodule Bot.Core.CommandHandler do
  require Logger

  alias Nosedrum.Storage.Dispatcher

  @server_list Application.compile_env(:bot, :guild_ids)
  @cmd_root_path "Elixir.Bot.Commands"
  @plugin_filename "./command.list"

  def handle_command(interaction) do
    Logger.info("Received command \"#{interaction.data.name}\" from user #{interaction.user.id}")
    Dispatcher.handle_interaction(interaction)
  end

  def register_commands() do
    case File.read(@plugin_filename) do
      {:ok, file_content} ->
        Logger.info("Command file loaded")
        String.split(file_content, "\n")
        |> map_to_modules
        |> register_modules_as_commands

      {:error, reason} ->
        Logger.error("Error reading command file: No commands loaded")
        Logger.debug("Could not load command file: #{reason}")
    end
  end

  def map_to_modules(string_list) do
    Logger.debug("Beginning module conversion")
    Enum.map(string_list, fn str ->
      Logger.debug("Converting #{str} to module #{@cmd_root_path}.#{str}")
      Enum.join([@cmd_root_path, str], ".") |> String.to_existing_atom
    end)
  end

  defp register_modules_as_commands(module_list) do
    Enum.each(module_list, fn module ->
      register_module_as_command(module)
    end)
  end

  defp register_module_as_command(module) do
    case length(@server_list) do
      0 ->
        Logger.debug("No server IDs specified, registering command #{module.name} globally")
        Dispatcher.add_command(module.name, module, :global)

      x when x > 0 ->
        Enum.each(@server_list, fn server ->
          Logger.debug("Registering module #{module} in server #{server} as command /#{module.name}")
          Dispatcher.add_command(module.name, module, server)
        end)

      _ -> Logger.error("Error registering #{module} as command")
    end
  end
end
