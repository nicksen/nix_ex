defmodule Nix.Dev.Command do
  @moduledoc false

  def run(command, opts \\ []) do
    command
    |> async(opts)
    |> await()
  end

  def async([exec | args], opts) do
    stream_fn = parse_stream_option(opts)
    cd = Keyword.get(opts, :cd, ".")
    exec_path = resolve_exec_path(exec, cd)

    env =
      opts
      |> Keyword.get(:env, %{})
      |> Enum.map(fn {key, val} -> {String.to_charlist(key), String.to_charlist(val)} end)

    spawn_opts = [
      :stream,
      :binary,
      :exit_status,
      :hide,
      :use_stdio,
      :stderr_to_stdout,
      args: args,
      cd: cd,
      env: env
    ]

    Task.async(fn ->
      start_time = System.monotonic_time()
      port = Port.open({:spawn_executable, exec_path}, spawn_opts)
      handle_port(port, stream_fn, "", opts[:silenced], start_time)
    end)
  end

  def await(task, timeout \\ :infinity) do
    {output, status, stream_fn, silenced, duration} = Task.await(task, timeout)
    if silenced, do: stream_fn.(output)

    {output, status, duration}
  end

  def unsilence(%Task{pid: pid} = task) do
    send(pid, :unsilence)
    task
  end

  defp handle_port(port, stream_fn, output, silenced, start_time) do
    receive do
      {^port, {:data, data}} ->
        data = if output == "", do: String.replace(data, ~r/^\s*/, ""), else: data
        unless silenced, do: stream_fn.(data)
        handle_port(port, stream_fn, output <> data, silenced, start_time)

      {^port, {:exit_status, status}} ->
        duration = System.monotonic_time() - start_time
        {output, status, stream_fn, silenced, duration}

      :unsilence ->
        stream_fn.(output)
        handle_port(port, stream_fn, output, false, start_time)
    end
  end

  @ansi_code_regex ~r/(\x1b\[[0-9;]*m)/

  defp parse_stream_option(opts) do
    case opts[:stream] do
      f when is_function(f) -> f
      true -> default_stream_fn(opts)
      falsy when falsy in [nil, false] -> fn _output -> nil end
    end
  end

  defp resolve_exec_path(exec, cd) do
    cond do
      Path.type(exec) == :absolute -> exec
      File.exists?(Path.join(cd, exec)) -> Path.expand(Path.join(cd, exec))
      path = System.find_executable(exec) -> path
      :else -> raise("executable not found: #{exec}")
    end
  end

  defp default_stream_fn(opts) do
    if opts[:tint] && IO.ANSI.enabled?() do
      fn output ->
        output
        |> String.replace(@ansi_code_regex, "\\1#{IO.ANSI.faint()}")
        |> IO.write()
      end
    else
      &IO.write/1
    end
  end
end
