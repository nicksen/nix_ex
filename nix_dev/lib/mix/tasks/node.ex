defmodule Mix.Tasks.Node do
  @shortdoc "Invokes node with the profile and args"

  @moduledoc """
  Invokes node with the given args.
  """

  use Mix.Task

  @impl Mix.Task
  def run([profile | args] = all) do
    Mix.Task.run("loadpaths")
    {:ok, _} = Application.ensure_all_started(:nix_dev)

    Mix.Task.reenable("node")

    case Nix.Dev.Command.Node.run(String.to_atom(profile), args) do
      0 -> :ok
      status -> Mix.raise("`mix node #{Enum.join(all, " ")}` exited with #{status}")
    end
  end

  @impl Mix.Task
  def run([]) do
    Mix.raise("`mix node` expects the profile as argument")
  end
end
