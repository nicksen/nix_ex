defmodule Nix.Dev.Command.NodeTest do
  use ExUnit.Case, async: true

  alias Nix.Dev.Command.Node

  test "run on default" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Node.run(:default, ["--version"]) == 0
           end)
  end

  test "run on profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Node.run(:script, ["foo"]) == 0
           end) =~ "foo"
  end
end
