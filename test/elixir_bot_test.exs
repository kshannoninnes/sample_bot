defmodule ElixirBotTest do
  use ExUnit.Case
  doctest ElixirBot

  test "greets the world" do
    assert ElixirBot.hello() == :world
  end
end
