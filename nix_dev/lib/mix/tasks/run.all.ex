defmodule Mix.Tasks.Run.All do
  @shortdoc "Executes mix tasks with wildcard support."

  @moduledoc """
  Executes mix tasks with wildcard support.
  """

  use Mix.Task

  alias Nix.Dev.Run

  @switches [
    list: :boolean
  ]

  @aliases [
    l: :list
  ]

  @impl Mix.Task
  def run(argv) do
    {opts, args} = OptionParser.parse!(argv, strict: @switches, aliases: @aliases)

    loadpaths!()

    mix_tasks = Stream.map(Mix.Task.load_all(), &Mix.Task.task_name/1)

    aliases =
      Mix.Project.config()
      |> Access.get(:aliases, [])
      |> Stream.map(&Atom.to_string(elem(&1, 0)))

    task_list = Stream.concat([aliases, mix_tasks])

    tasks =
      task_list
      |> Enum.sort()
      |> Run.All.match_tasks(args)

    if opts[:list] do
      print_tasks(tasks)
    end
  end

  ## priv

  defp print_tasks(tasks) do
    tasks
    |> Enum.join("\n")
    |> Mix.shell().info()
  end

  defp loadpaths! do
    args = ["--no-elixir-version-check", "--no-deps-check", "--no-archive-check"]
    Mix.Task.run("loadpaths", args)
    Mix.Task.reenable("loadpaths")
    Mix.Task.reenable("deps.loadpaths")
  end
end
