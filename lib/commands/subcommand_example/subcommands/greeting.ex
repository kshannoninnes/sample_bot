defmodule Bot.Commands.SubcommandExample.Subcommands.Greeting do
  # Because this command had an optional second argument, we need to pattern match to extract that argument
  # This helper module does that, rather than cluttering up the discord command

  # Each argument in the list is a map containing the argument's attributes
  def say_hi([first_name, last_name]),
    do: "Hi there, #{first_name.value} #{last_name.value}"

  def say_hi([first_name]),
    do: "Hi there, #{first_name.value}"
end
