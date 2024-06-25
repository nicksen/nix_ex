defmodule Mix.Tasks.Run.Tasks do
  @shortdoc "Run tasks in a project"

  @moduledoc """
  A task to efficiently run other tasks in a project.
  """

  use Mix.Task

  alias Nix.Dev.TaskRunner
  alias Nix.Dev.TaskRunner.Context

  @impl Mix.Task
  def run(args) do
    args
    |> Context.new!()
    |> TaskRunner.run_each()
  end
end
