defmodule Nix.Dev.Command.NpmTest do
  use ExUnit.Case, async: true

  alias Nix.Dev.Command.Npm

  test "run on default" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Npm.run(:default, ["--version"]) == 0
           end)
  end

  test "run on profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Npm.run(:npm_cmd, []) == 0
           end)
  end
end
