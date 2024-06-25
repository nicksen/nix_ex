defmodule Nix.Dev.TaskRunner do
  @moduledoc false

  alias Nix.Dev.TaskRunner.Context
  alias Nix.Dev.TaskRunner.Printer

  @doc """
  Run each command
  """
  @spec run_each(Context.t()) :: :ok
  def run_each(ctx) do
    {total_duration, all_results} =
      ctx
      |> tap(&Printer.info(inspect(&1)))
      |> run_tasks_timed()

    # commands = Context.commands(ctx)

    # timing_unit = :microsecond
    # {total_duration, all_results} = :timer.tc(fn -> run_tasks(commands, ctx) end, timing_unit)
    # start_time = System.monotonic_time()
    # all_results = run_tasks(commands, config)
    # total_duration = System.monotonic_time() - start_time

    # failed_results = Enum.filter(all_results, &match?({:error, _tool, _opts}, &1))

    # reprint_errors(failed_results)
    # # print_summary(all_results, total_duration, opts)
    # maybe_set_exit_status(failed_results)

    print_results(all_results, total_duration, ctx)
  end

  ## priv

  defp run_tasks_timed(ctx) do
    commands = Context.commands(ctx)
    Context.timed(ctx, fn -> run_tasks(commands, ctx) end)
  end

  defp run_tasks(commands, _ctx) do
    for [task | args] <- commands do
      Printer.info("run '#{Enum.join([task | args], " ")}'")
      Mix.Task.run(task, args)
    end
  end

  defp print_results(results, duration, _ctx) do
    for {:error, {tool, _args, _tool_opts}, {_status, output, _}} <- results do
      Printer.info([:red, "=> reprinting errors from ", format_tool_name(tool)])
      Printer.info()

      Printer.info(output)
      Printer.info()
    end

    Printer.info([:magenta, "=> finished in ", :bright, format_duration(duration)])
    Printer.info()
  end

  defp format_duration({duration, unit}) do
    duration
    |> System.convert_time_unit(unit, :microsecond)
    |> then(&Duration.new!(microsecond: {&1, 6}))
    |> Duration.to_iso8601()
  end

  defp format_tool_name(name) when is_atom(name) do
    b(name)
  end

  defp format_tool_name({name, app}) when is_atom(name) do
    [b(name), " in ", b(app)]
  end

  defp b(inner) do
    [:bright, to_string(inner), :normal]
  end
end
