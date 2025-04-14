defmodule Mix.Tasks.Poncho.Do do
  @shortdoc "Executes the tasks in all mix projects in the current directory"

  @moduledoc """
  Executes the tasks (like `mix do`) in all parts of the poncho project in the current directory.

  The projects are loaded, inspected, and sorted so that the tasks are first run on the leaves of
  the dependency tree, moving back to the DAG root. This prevents repeated project building (in
  `:prod` and `:test` envs), loading, and polluting VM runtime.
  """

  use Mix.Task

  alias Mix.Dep
  alias Mix.Dep.Converger
  alias Mix.Dep.Loader
  alias Mix.Project

  @impl Mix.Task
  def run(args) do
    projects = list_projects!()
    commands = gather_commands(args)

    sorted =
      projects
      |> Enum.map(&load_dep_from_path/1)
      |> sort_deps()

    for dep <- sorted, [task | args] <- commands do
      Mix.shell().info("==> #{dep.app}")
      path = dep.opts[:path]

      Project.in_project(dep.app, path, fn _module ->
        Mix.Task.run(task, args)
      end)
    end
  end

  ## priv

  defp gather_commands(args) do
    [args]
  end

  defp load_dep_from_path(dir) do
    app =
      dir
      |> path_to_dep()
      |> load_dep()

    available_deps = Enum.filter(app.deps, &Dep.available?/1)

    %{app | deps: available_deps}
  end

  defp list_projects! do
    Enum.filter(File.ls!(), &(File.dir?(&1) and mix_project?(&1)))
  end

  defp sort_deps(deps) do
    Converger.topological_sort(deps)
  end

  defp mix_project?(dir) do
    dir
    |> Path.join(mix_file())
    |> File.regular?()
  end

  defp mix_file do
    System.get_env("MIX_EXS", "mix.exs")
  end

  defp load_dep(dep) do
    Loader.load(dep, nil, true)
  end

  defp path_to_dep(dir) do
    path = Path.expand(dir)
    build = Path.join(path, "_build")

    %Dep{
      scm: Mix.SCM.Path,
      app: String.to_atom(dir),
      manager: :mix,
      status: {:ok, nil},
      opts: [
        path: path,
        dest: path,
        build: build,
        env: Mix.env()
      ]
    }
  end
end
