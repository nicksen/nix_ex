defmodule NixTotpTest do
  use ExUnit.Case
  doctest NixTotp

  test "greets the world" do
    assert NixTotp.hello() == :world
  end
end
