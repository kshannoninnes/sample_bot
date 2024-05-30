defmodule Bot.Commands.SubcommandExample.Command do
  @behaviour Nosedrum.ApplicationCommand

  alias Bot.Commands.SubcommandExample.Subcommands.Greeting, as: Greeting

  def name(), do: "subcommand_example"

  @impl true
  def description(), do: "Demonstrating how to use sub commands"

  @impl true
  def command(interaction) do
    [content: process_subcommand(interaction.data.options)]
  end

  # I would probably recommend moving all of this subcommand processing into its own module
  def process_subcommand([%{name: "yes_or_no", options: yes_or_no_args}]),
    do: yes_or_no_args.value

  def process_subcommand([%{name: "greeting", options: greeting_args}]),
    do: Greeting.say_hi(greeting_args)

  # Continue traversing options until we reach one of the subcommands above
  def process_subcommand([%{options: next_layer}]) when next_layer != nil,
    do: process_subcommand(next_layer)

  # This should never be reached, assuming you correctly pattern match the sub-command names above
  def process_subcommand(_),
    do: "Error finding sub-command. Are you sure you're matching the correct sub-command names?"

  @impl true
  def options do
    [
      %{
        # Sub-command groups act as a kind of "folder" for sub-commands
        type: :sub_command_group,
        # Users will NOT see this name in discord
        name: "sub_command_group",
        # Or this description
        description: "group description",
        # Sub-command group options are a list of sub-commands
        options: [
          %{
            # Sub-commands represent the actual command you're invoking
            type: :sub_command,
            name: "yes_or_no",
            description: "the nested command",
            # Sub-command options are the arguments you expect to get back
            options: [
              %{
                # What type is the argument the user needs to provide?
                type: :string,
                # The user will see this argument name in discord
                name: "user_choice",
                description: "Choose yes or no",
                # Not all arguments are required, as you'll see in the greeting command below
                required: true,
                # Choices restrict the potential values users can pass into this sub-command. In this case only "yes" or "no"
                choices: [
                  %{
                    # The name is what the user in discord will see as one of the available choices
                    name: "yes",
                    # The value is what you will get back in the interaction object based on which choice name the user passed in
                    value: "You chose yes!"
                  },
                  %{
                    name: "no",
                    value: "You chose no!"
                  }
                ]
              }
            ]
          }
        ]
      },
      # This sub-command is not part of the sub_command_group like the yes_or_no sub-command above
      %{
        type: :sub_command,
        name: "greeting",
        description: "Greet the user with their name",
        options: [
          %{
            type: :string,
            name: "first_name",
            description: "Your first name",
            required: true
          },
          %{
            type: :string,
            name: "last_name",
            description: "Your last name",
            # false is the default but we're being explicit for the sake of demonstration
            required: false
          }
        ]
      }
    ]
  end

  @impl true
  def type(), do: :slash
end
