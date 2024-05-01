defmodule Mix.Tasks.Nix.Lint.Setup do
  @shortdoc "Setup lint tools"

  @moduledoc """
  Setup lint tools for a project.
  """

  use Mix.Task

  alias Nix.Lint.Setup

  @switches [
    except: :keep,
    only: :keep
  ]

  @aliases [
    o: :only,
    x: :except
  ]

  @impl Mix.Task
  def run(argv) do
    {opts, _args} = OptionParser.parse!(argv, strict: @switches, aliases: @aliases)

    opts
    |> process_opts()
    |> Setup.run()
  end

  defp process_opts(opts) do
    Enum.map(opts, fn
      {:except, name} -> {:except, String.to_existing_atom(name)}
      {:only, name} -> {:only, String.to_existing_atom(name)}
      opt -> opt
    end)
  end
end
