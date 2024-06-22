defmodule Mix.Tasks.Npm do
  @shortdoc "Invokes npm with the profile and args"

  @moduledoc """
  Invokes npm with the given args.
  """

  use Mix.Task

  alias Nix.Dev.Command.Npm

  @impl Mix.Task
  def run([profile | args] = all) do
    Mix.Task.run("loadpaths")
    {:ok, _} = Application.ensure_all_started(:nix_dev)

    Mix.Task.reenable("npm")

    case Npm.run(String.to_atom(profile), args) do
      0 -> :ok
      status -> Mix.raise("`mix npm #{Enum.join(all, " ")}` exited with #{status}")
    end
  end

  @impl Mix.Task
  def run([]) do
    Mix.raise("`mix npm` expects the profile as argument")
  end
end
