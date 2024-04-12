defmodule Bot.Core.CommandHandler do
  require Logger

  alias Nosedrum.Storage.Dispatcher

  @server_id Application.compile_env(:bot, :guild_id)
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
        String.split(file_content, "\n") |> to_modules |> to_commands

      {:error, reason} ->
        Logger.error("Error reading command file: No commands loaded")
        Logger.debug("Could not load command file: #{reason}")
    end
  end

  def to_modules(string_list) do
    Logger.debug("Beginning module conversion")
    Enum.map(string_list, fn str ->
      Logger.debug("Converting #{str} to module #{@cmd_root_path}.#{str}")
      Enum.join([@cmd_root_path, str], ".") |> String.to_existing_atom
    end)
  end

  defp to_commands(module_list) do
    Enum.each(module_list, fn module ->
      Logger.debug("Registering command \"#{module.name}\"")
      Dispatcher.add_command(module.name, module, @server_id)
    end)
  end
end
