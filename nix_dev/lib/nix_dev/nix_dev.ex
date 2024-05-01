defmodule Nix.Dev do
  @moduledoc false

  alias Nix.Dev.Command
  alias Nix.Dev.Pipeline
  alias Nix.Dev.Printer

  @tools [
    compiler: "mix compile --force --all-warnings --warnings-as-errors",
    unused_deps: {"mix deps.unlock --check-unused", fix: "mix do deps.unlock --unused + deps.clean --unused"},
    formatter: {"mix format --check-formatted", fix: "mix format"},
    hex_audit: "mix hex.audit",
    mix_audit: "mix deps.audit",
    xref: "mix xref graph --label compile-connected --fail-above 0",
    credo: "mix credo suggest",
    recode: {"mix recode", fix: "mix recode --autocorrect"},
    dialyzer: "mix dialyzer"
  ]

  def run(opts) do
    start = System.monotonic_time()

    results =
      @tools
      |> prepare_tasks(opts)
      |> run_tasks(opts)

    duration = System.monotonic_time() - start
    failed = Enum.filter(results, &match?({:error, _task, _result}, &1))

    reprint_errors(failed)
    print_summary(results, duration, opts)
  end

  defp run_tasks(tasks, opts) do
    {finished, skipped} =
      Pipeline.run(tasks,
        throttle_fn: &throttle_tools(&1, &2, &3, opts),
        start_fn: &start_tool/1,
        collect_fn: &await_tool/1
      )

    finished ++ skipped
  end

  defp throttle_tools(pending, [], _finished, _opts), do: Enum.take(pending, 1)
  defp throttle_tools(_pending, _running, _finished, _opts), do: []

  defp start_tool({name, cmd, opts}) do
    opts = Keyword.merge(opts, stream: true, silenced: true, tint: IO.ANSI.faint())
    task = Command.async(cmd, opts)

    {{name, cmd, opts}, task}
  end

  defp await_tool({{name, cmd, opts}, task}) do
    Printer.info([:magenta, "=> running " | format_tool_name(name)])
    Printer.info()
    IO.write(IO.ANSI.faint())

    {output, code, duration} =
      task
      |> Command.unsilence()
      |> Command.await()

    if output_needs_padding?(output), do: Printer.info()
    IO.write(IO.ANSI.reset())
    status = if code == 0, do: :ok, else: :error

    {status, {name, cmd, opts}, {code, output, duration}}
  end

  defp prepare_tasks(tools, opts) do
    for tool <- tools do
      tool
      |> normalize_task()
      |> prepare_task(opts)
    end
  end

  defp prepare_task({name, tool_opts}, opts) do
    cmd =
      tool_opts
      |> resolve_cmd(opts)
      |> cmd_to_list()

    cmd_opts = Keyword.take(tool_opts, [:cd, :deps, :env])

    {name, cmd, cmd_opts}
  end

  defp cmd_to_list(cmd) when is_list(cmd), do: cmd
  defp cmd_to_list(cmd), do: String.split(cmd, " ", trim: true)

  defp resolve_cmd(tool, opts) do
    if opts[:fix] && tool[:fix] do
      tool[:fix]
    else
      Keyword.fetch!(tool, :cmd)
    end
  end

  defp normalize_task({name, [{_, _} | _]} = opts), do: {name, opts}
  defp normalize_task({name, cmd}) when is_binary(cmd), do: {name, cmd: cmd}
  defp normalize_task({name, [bin | _] = cmd}) when is_binary(bin), do: {name, cmd: cmd}
  defp normalize_task({name, {cmd}}) when is_binary(cmd), do: {name, cmd: cmd}
  defp normalize_task({name, {[bin | _] = cmd}}) when is_binary(bin), do: {name, cmd: cmd}

  defp normalize_task({name, {cmd, [{_, _} | _] = opts}}) when is_binary(cmd), do: {name, Keyword.put(opts, :cmd, cmd)}

  defp normalize_task({name, {[bin | _] = cmd, [{_, _} | _] = opts}}) when is_binary(bin),
    do: {name, Keyword.put(opts, :cmd, cmd)}

  defp reprint_errors(failed) do
    Enum.each(failed, fn {_status, {name, _cmd, _task_opts}, {_code, output, _duration}} ->
      Printer.info([:red, "=> reprinting errors from " | format_tool_name(name)])
      Printer.info()
      IO.write(output)
      if output_needs_padding?(output), do: Printer.info()
    end)
  end

  defp print_summary(items, duration, opts) do
    Printer.info([:magenta, "=> finished in ", :bright, format_duration(duration)])
    Printer.info()

    items
    |> Enum.sort_by(&summary_item_order/1)
    |> Enum.each(&print_summary_item(&1, opts))

    Printer.info()
  end

  defp print_summary_item({:ok, {name, _cmd, _task_opts}, {_code, _output, duration}}, _opts) do
    Printer.info([
      :green,
      " ✓ ",
      format_tool_name(name),
      " success in ",
      format_duration(duration)
    ])
  end

  defp print_summary_item({:error, {name, _cmd, _task_opts}, {code, _output, duration}}, _opts) do
    Printer.info([
      :red,
      " ✕ ",
      format_tool_name(name),
      " error code ",
      b(code),
      " in ",
      format_duration(duration)
    ])
  end

  defp summary_item_order({:ok, {name, _cmd, _opts}, _result}), do: {0, name}
  defp summary_item_order({:error, {name, _cmd, _opts}, _result}), do: {1, name}

  defp format_tool_name({name, app}) when is_atom(name) do
    [b(name), " in ", b(app)]
  end

  defp format_tool_name(name) when is_atom(name) do
    b(name)
  end

  defp format_duration(duration) do
    secs = System.convert_time_unit(duration, :native, :second)
    mins = div(secs, 60)
    s_rem = rem(secs, 60)
    s_pad = if s_rem < 10, do: "0#{s_rem}", else: "#{s_rem}"

    "#{mins}:#{s_pad}"
  end

  defp b(data) do
    [:bright, to_string(data), :normal]
  end

  defp output_needs_padding?(output) do
    not (String.match?(output, ~r/\n{2,}$/) or output == "")
  end
end
