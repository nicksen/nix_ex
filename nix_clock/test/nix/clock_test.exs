defmodule Nix.ClockTest do
  use ExUnit.Case
  doctest Nix.Clock

  test "greets the world" do
    assert Nix.Clock.hello() == :world
  end
end
