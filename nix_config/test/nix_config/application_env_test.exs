defmodule Nix.Config.ApplicationEnvTest do
  use Nix.ConfigCase, async: false

  import Nix.Config

  describe "app_env" do
    @tag app_env: [test: "env"]
    test "get app env key" do
      assert app_env([:test]) == "env"
    end

    @tag app_env: [a: [b: "nested"]]
    test "get nested app env" do
      assert app_env([:a, :b]) == "nested"
    end

    @tag app_env: []
    test "fallback to default" do
      assert app_env([:a], "default") == "default"
    end
  end

  describe "app_env!" do
    @tag app_env: [test: "env"]
    test "fetch app env key" do
      assert app_env!([:test]) == "env"
    end

    @tag app_env: [a: %{b: "nested"}]
    test "fetch nested app env" do
      assert app_env!([:a, :b]) == "nested"
    end

    @tag app_env: []
    test "error when fetching missing app env" do
      assert_raise KeyError, fn -> app_env!([:missing]) end
    end

    @tag app_env: [nested: %{a: 1}]
    test "error when fetching missing nested app env" do
      assert_raise KeyError, fn -> app_env!([:nested, :missing]) end
    end
  end
end
