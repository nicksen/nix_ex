defmodule Nix.Ticker do
  @moduledoc """
  Processes to periodically trigger a function.
  """

  alias Nix.Ticker.Timer

  @doc """
  Start a timer.
  """
  @spec start_timer(Timer.callable(), Timer.options()) :: Supervisor.on_start()
  def start_timer(callable, opts \\ []) do
    Timer.register_new(callable, opts)
  end

  @doc """
  Get a list of pids of timers.
  """
  @spec list() :: [pid]
  def list do
    for {:undefined, pid, :worker, [Nix.Ticker.Timer]} <- Timer.which_children(), do: pid
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
  @spec terminate(pid) :: :ok | {:error, :not_found}
  def terminate(pid) do
    Timer.terminate_timer(pid)
  end
end
