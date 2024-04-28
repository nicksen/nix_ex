defmodule Nix.StdTest do
  use ExUnit.Case
  doctest Nix.Std

  test "greets the world" do
    assert Nix.Std.hello() == :world
  end
end
