defmodule MatchTasksAssertions do
  @moduledoc false

  alias Nix.Dev.Run

  @tasks [
    "start",
    "stop",
    "pkg.cfg",
    "pkg.cfg2",
    "nested.pkg.cfg",
    "cfg",
    "cfg2",
    "nested.cfg",
    "append",
    "append.a",
    "append.a.c",
    "append.a.d",
    "append.b",
    "append1",
    "append2",
    "abort",
    "error",
    "stdout",
    "stderr",
    "stdin",
    "echo",
    "dump",
    "nest.append.run.all",
    "nest.append.run.s",
    "nest.append.run.p",
    "delayed",
    "yarn",
    "!test",
    "?test"
  ]

  defmacro assert_tasks({op, meta, [left, right]} = expr) do
    actual = Macro.var(:tasks, __MODULE__)
    meta = Keyword.put(meta, :no_parens, true)
    assertion = {op, meta, [actual, right]}
    expr = Macro.escape({:assert_tasks, meta, [expr]}, prune_metadata: true)

    quote do
      tasks = Run.All.match_tasks(unquote(@tasks), unquote(List.wrap(left)))

      ExUnit.Assertions.assert(unquote(assertion),
        left: unquote(actual),
        right: unquote(right),
        expr: unquote(expr),
        context: :==
      )
    end
  end
end
