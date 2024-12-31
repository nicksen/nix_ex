defmodule NixMarkdownFormatterTest do
  use ExUnit.Case
  doctest NixMarkdownFormatter

  test "greets the world" do
    assert NixMarkdownFormatter.hello() == :world
  end
end
