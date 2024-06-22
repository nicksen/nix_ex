defmodule Nix.Dev.Command.NpxTest do
  use ExUnit.Case, async: true

  alias Nix.Dev.Command.Npx

  test "run on default" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Npx.run(:default, ["--version"]) == 0
           end)
  end

  test "run on profile" do
    assert ExUnit.CaptureIO.capture_io(fn ->
             assert Npx.run(:npx_cmd, []) == 0
           end)
  end
end
