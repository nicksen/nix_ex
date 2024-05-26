defmodule Nix.Dev.Run.All.MatchTasks do
  @moduledoc false

  alias Nix.Dev.Run.All.Matcher
  alias Nix.Dev.Run.All.TaskSet

  ## api

  @doc """
  Enumerates tasks that matches a pattern.
  """
  @spec run([String.t()], [String.t()]) :: Enumerable.t(String.t())
  def run(task_list, patterns) do
    matchers = Enum.map(patterns, &create_matcher/1)
    candidates = Enum.map(task_list, &swap_symbols/1)

    task_set =
      for matcher <- matchers, candidate <- candidates, reduce: TaskSet.new() do
        acc -> match_task(acc, matcher, candidate)
      end

    TaskSet.to_list(task_set)
  end

  ## priv

  defp match_task(task_set, matcher, candidate) do
    if Matcher.match?(matcher, candidate) do
      command = String.trim("#{swap_symbols(candidate)} #{matcher.args}")
      source = matcher.task
      TaskSet.add(task_set, command, source)
    else
      task_set
    end
  end

  defp create_matcher(pattern) do
    trimmed = String.trim(pattern)

    {task, args} =
      case String.split(trimmed, " ", parts: 2) do
        [task] -> {task, ""}
        [task, args] -> {task, args}
      end

    task
    |> swap_symbols()
    |> Matcher.new!(task, args)
  end

  defp swap_symbols(name) do
    Regex.replace(~r/[\.\/]/, name, &swap/1)
  end

  defp swap("."), do: "/"
  defp swap("/"), do: "."
end
