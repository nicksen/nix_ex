defmodule Mix.Tasks.Run.Tasks do
  @shortdoc "Run tasks in a project"

  @moduledoc """
  A task to efficiently run other tasks in a project.
  """

  use Mix.Task

  alias Nix.Dev.TaskRunner

  @switches [
    jobs: :integer,
    timing_unit: :string
  ]
  @aliases [
    j: :jobs
  ]

  ## impl

  @impl Mix.Task
  def run(args) do
    {opts, args} = OptionParser.parse_head!(args, strict: @switches, aliases: @aliases)

    args
    |> gather_commands([], [])
    |> TaskRunner.run!(opts)
  end

  ## priv

  defp gather_commands([], current, acc) do
    Enum.reverse([Enum.reverse(current) | acc])
  end

  defp gather_commands(["::" | rest], current, acc) do
    gather_commands(rest, [], [Enum.reverse(current) | acc])
  end

  defp gather_commands([head | tail], current, acc) do
    gather_commands(tail, [head | current], acc)
  end
end
