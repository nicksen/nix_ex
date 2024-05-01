defmodule Mix.Tasks.Lint do
  @shortdoc "Lint a project source files"
  @moduledoc ""

  use Mix.Task

  @requirements ["app.config"]

  @switches [
    fix: :boolean
  ]

  @aliases [
    f: :fix
  ]

  @impl Mix.Task
  def run(args) do
    {opts, _args} = OptionParser.parse!(args, strict: @switches, aliases: @aliases)
    Nix.Dev.run(opts)
  end
end
