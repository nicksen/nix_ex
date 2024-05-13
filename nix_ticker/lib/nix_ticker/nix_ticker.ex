defmodule Nix.Ticker do
  @moduledoc """
  Create timers that repeatedly triggers a process, with a fixed time delay between triggers.
  """

  alias Nix.Ticker.Timer

  @options_schema NimbleOptions.new!(
                    interval: [
                      type: :pos_integer,
                      default: 10_000,
                      doc: "how often a timer should trigger (in ms)"
                    ]
                  )

  ## types

  @type task :: (pid -> any)

  @type callable :: task | {module, atom} | {module, atom, [any]}
  @type options :: [unquote(NimbleOptions.option_typespec(@options_schema))]

  ## api

  @doc """
  Starts a timer.

  The `callable` can be a 1-arity function, a `{Mod, :fun}` tuple, or a `{Mod, :fun, [arg1, ...]}`
  tuple. It will be called with the pid of the timer (the pid is prepended to the list of
  arguments if specified).

  ## Options

  #{NimbleOptions.docs(@options_schema)}

  ## Examples

      iex> Ticker.start_timer(&IO.inspect/1)
      {:ok, #PID<0.133.0>}

      iex> Ticker.start_timer({MyMod, :fun})
      {:ok, #PID<0.134.0>}

      iex> Ticker.start_timer({MyMod, :fun, [node(), self()]})
      {:ok, #PID<0.140.0>}
  """
  @spec start_timer(callable, keyword) :: {:ok, pid} | {:error, {:already_started, pid}}
  def start_timer(callable, opts \\ []) do
    opts = NimbleOptions.validate!(opts, @options_schema)
    Timer.register_new(callable, opts)
  end

  @doc """
  Get a list of pids of timers.

  ## Examples

      iex> Ticker.list()
      [#PID<0.120.0>, ...]
  """
  @spec list() :: [pid]
  def list do
    for {:undefined, pid, :worker, [Timer]} <- Timer.which_children(), do: pid
  end

  @doc """
  Change the interval of a running timer.
  """
  @spec change_interval(GenServer.server(), pos_integer) :: :ok
  def change_interval(pid, interval) do
    Timer.change_interval(pid, interval)
  end

  @doc """
  Terminate the timer.
  """
  @spec terminate(GenServer.server()) :: :ok | {:error, :not_found}
  def terminate(pid) do
    Timer.terminate_timer(pid)
  end
end
