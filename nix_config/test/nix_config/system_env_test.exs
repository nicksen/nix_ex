defmodule Nix.Config.SystemEnvTest do
  use Nix.ConfigCase, async: false

  import Nix.Config

  describe "os_env" do
    @tag setenv: [test: "set"]
    test "get system environment variable" do
      assert os_env("test") == "set"
    end

    @tag setenv: [test: nil]
    test "fallback to default" do
      assert os_env("test", "default") == "default"
    end

    @tag setenv: [test: nil]
    test "get unset" do
      assert os_env("test") == nil
    end
  end

  describe "os_env!" do
    @tag setenv: [env: "val"]
    test "fetch env var" do
      assert os_env!("env") == "val"
    end

    @tag setenv: [unset: nil]
    test "error when fetching unset variable" do
      assert_raise System.EnvError, fn -> os_env!("unset") end
    end
  end
end
