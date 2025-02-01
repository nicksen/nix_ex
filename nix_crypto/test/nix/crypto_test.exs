defmodule Nix.CryptoTest do
  use ExUnit.Case
  doctest Nix.Crypto

  test "greets the world" do
    assert Nix.Crypto.hello() == :world
  end
end
