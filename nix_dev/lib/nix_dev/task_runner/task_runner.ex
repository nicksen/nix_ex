defmodule Nix.Dev.TaskRunner do
  @moduledoc false

  alias Nix.Dev.TaskRunner.Config
  alias Nix.Dev.TaskRunner.Pipeline
  alias Nix.Dev.TaskRunner.Printer

  ## api

  @spec run!([[String.t(), ...]], keyword) :: term
  def run!(commands, opts) do
    config = Config.load!(opts)

    tasks =
      for [task | args] <- commands do
        config
        |> Config.pipeline(task)
        |> Enum.map(&prepare_pending(&1, config))
      end

    {finished, broken} = Pipeline.run(tasks, config)
  end

  ## priv

  defp prepare_pending({task, opts}, config) do
    pipe = Config.pipeline(config, task)
  end

  defp run_commands(commands, config) do
    for [task | args] <- commands do
      name = String.to_atom(task)

      if pipe = config[:tasks][name] do
        for group <- pipe, command <- group do
          run_command(command, args)
        end
      else
        run_command(task, args)
      end
    end
  end

  defp run_command(command, args) do
    Printer.info([:faint, :magenta, "=> Running ", format_task_name(command)])

    # Mix.Task.run(command, args)

    Mix.shell().cmd(Enum.join(["mix", command | args], " "), env: %{}, stderr_to_stdout: true)
  end

  defp format_task_name(name) do
    [:bright, name, :normal]
  end
end
