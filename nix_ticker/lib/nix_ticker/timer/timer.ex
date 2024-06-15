defmodule Nix.Ticker.Timer do
  @moduledoc false

  use GenServer

  alias Nix.Ticker.Timer.State

  require Logger

  @tick_event :tick
  @schedule_tick_event :schedule_tick
  @change_interval_event :change_interval

  @continue_schedule {:continue, @schedule_tick_event}

  @supervisor Nix.Ticker.TimerSupervisor
  @tasks Nix.Ticker.TaskSupervisor

  ## types

  @type on_start :: Nix.Ticker.on_start()

  ## api

  @doc """
  Start and supervise a new timer.
  """
  @spec register_new(Nix.Ticker.callable(), Nix.Ticker.options()) :: on_start
  def register_new(callable, opts) do
    DynamicSupervisor.start_child(@supervisor, {__MODULE__, {callable, opts}})
  end

  @doc """
  Start a timer process linked to the current process.
  """
  @spec start_link({Nix.Ticker.callable(), Nix.Ticker.options()}, GenServer.options()) ::
          GenServer.on_start()
  def start_link(init_arg, options \\ []) do
    GenServer.start_link(__MODULE__, init_arg, options)
  end

  @doc """
  Returns a list of pids of currently running timers.
  """
  @spec which_children() :: [
          {:undefined, pid | :restarting, :worker | :supervisor, [module] | :dynamic}
        ]
  def which_children do
    DynamicSupervisor.which_children(@supervisor)
  end

  @doc """
  Update the interval of a running timer.
  """
  @spec change_interval(pid, pos_integer) :: :ok
  def change_interval(pid, interval) when is_pid(pid) and is_integer(interval) and interval > 0 do
    GenServer.cast(pid, {@change_interval_event, interval})
  end

  @doc """
  Terminates a timer.
  """
  @spec terminate_timer(pid) :: :ok | {:error, :not_found}
  def terminate_timer(pid) do
    DynamicSupervisor.terminate_child(@supervisor, pid)
  end

  @doc """
  Synchronously stops a timer with the given `reason`.

  If the timer is running under a supervisor, it may later be restarted depending on the
  supervisors `:restart` configuration.
  """
  @spec stop(pid, term) :: :ok
  def stop(pid, reason \\ :normal) when is_pid(pid) do
    GenServer.stop(pid, reason)
  end

  ## callbacks

  @impl GenServer
  @spec init({Nix.Ticker.callable(), Nix.Ticker.options()}) :: {:ok, State.t(), {:continue, term}}
  def init({callable, opts}) do
    state =
      opts
      |> Keyword.put(:task, normalize_callable(callable))
      |> State.new()

    {:ok, state, @continue_schedule}
  end

  @impl GenServer
  def handle_cast({@change_interval_event, interval}, state) do
    _cancellation =
      if timer_ref = state.timer_ref do
        Process.cancel_timer(timer_ref)
      end

    {:noreply, State.update(state, interval: interval, timer_ref: nil), @continue_schedule}
  end

  @impl GenServer
  def handle_info(@tick_event, %{task: task} = state) do
    this = self()

    case Task.Supervisor.start_child(@tasks, fn -> task.(this) end) do
      {:ok, _pid} -> :noop
      {:error, reason} -> Logger.error("failed to trigger task, reason: #{inspect(reason)}")
    end

    {:noreply, State.update(state, timer_ref: nil), @continue_schedule}
  end

  @impl GenServer
  @spec handle_continue(:schedule_tick, State.t()) :: {:noreply, State.t()}
  def handle_continue(@schedule_tick_event, %{timer_ref: nil} = state) do
    timer_ref = Process.send_after(self(), @tick_event, state.interval)
    {:noreply, State.update(state, timer_ref: timer_ref)}
  end

  ## priv

  defp normalize_callable(fun) when is_function(fun, 1), do: fun
  defp normalize_callable({mod, fun}), do: capture(mod, fun, [])
  defp normalize_callable({mod, fun, args}), do: capture(mod, fun, args)

  defp capture(mod, fun, extra_args) do
    args =
      extra_args
      |> List.wrap()
      |> wrap_keyword_list()

    fn pid -> apply(mod, fun, [pid | args]) end
  end

  defp wrap_keyword_list(term) do
    if Keyword.keyword?(term), do: [term], else: term
  end
end
