defmodule Nix.Dev.TaskRunner.ContextTest do
  use ExUnit.Case, async: true

  alias Nix.Dev.TaskRunner.Context

  describe "commands/1" do
    test "read from command line" do
      ctx = ctx("compile")
      assert Context.commands(ctx) == [["compile"]]
    end

    test "read command and arguments from command line" do
      ctx = ctx("compile --force")
      assert Context.commands(ctx) == [["compile", "--force"]]
    end

    test "read tasks from command line" do
      ctx = ctx("compile + format")
      assert Context.commands(ctx) == [["compile"], ["format"]]
    end

    test "read tasks with arguments from command line" do
      ctx = ctx("compile --dry-run + format --force")
      assert Context.commands(ctx) == [["compile", "--dry-run"], ["format", "--force"]]
    end
  end

  describe "options" do
    test "parse task flags" do
      ctx = ctx("--jobs 2 foo -x + bar -y")

      assert ctx.opts[:jobs] == 2
      assert Context.commands(ctx) == [["foo", "-x"], ["bar", "-y"]]
    end

    test "parse all task flags" do
      ctx = ctx("-j 20 --timing-unit s foo -x + bar -y")

      assert ctx.opts[:jobs] == 20
      assert ctx.opts[:timing_unit] == :second
    end
  end

  defp ctx(args) do
    args
    |> String.split(" ")
    |> Context.new!()
  end
end
