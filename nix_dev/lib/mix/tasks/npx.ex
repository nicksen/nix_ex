defmodule Mix.Tasks.Npx do
  @shortdoc "Invokes npx with the profile and args"

  @moduledoc """
  Invokes npx with the given args.
  """

  use Mix.Task

  alias Nix.Dev.Command.Npx

  @impl Mix.Task
  def run([profile | args] = all) do
    Mix.Task.run("loadpaths")
    {:ok, _} = Application.ensure_all_started(:nix_dev)

    Mix.Task.reenable("npx")

    case Npx.run(String.to_atom(profile), args) do
      0 -> :ok
      status -> Mix.raise("`mix npx #{Enum.join(all, " ")}` exited with #{status}")
    end
  end

  @impl Mix.Task
  def run([]) do
    Mix.raise("`mix npx` expects the profile as argument")
  end
end
