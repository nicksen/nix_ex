defmodule Nix.Ticker.Timer do
  @moduledoc false

  use GenServer

  require Logger

  @supervisor Nix.Ticker.TimerSupervisor
  @tasks Nix.Ticker.TaskSupervisor

  @options_schema NimbleOptions.new!(
                    interval: [
                      type: :pos_integer,
                      default: 10_000,
                      doc: "how often this timer should trigger (in ms)"
                    ]
                  )

  ## types

  @type callable :: (pid -> any) | {module, atom} | {module, atom, [any]}
  @type options :: [unquote(NimbleOptions.option_typespec(@options_schema))]

  @typep state :: %{
           task: (pid -> any),
           interval: pos_integer,
           timer_ref: reference | nil
         }

  ## api

  @doc false
  @spec start_link({callable, options}, GenServer.options()) :: GenServer.on_start()
  def start_link({_callable, _opts} = init_arg, options \\ []) do
    GenServer.start_link(__MODULE__, init_arg, options)
  end

  @spec register_new(callable, options) :: Supervisor.on_start()
  def register_new(callable, opts) do
    opts = NimbleOptions.validate!(opts, @options_schema)
    DynamicSupervisor.start_child(@supervisor, {__MODULE__, {callable, opts}})
  end

  @spec which_children() :: [
          {:undefined, pid | :restarting, :worker | :supervisor, [module] | :dynamic}
        ]
  def which_children do
    DynamicSupervisor.which_children(@supervisor)
  end

  @spec change_interval(GenServer.server(), pos_integer) :: :ok
  def change_interval(server, interval) when is_integer(interval) and interval > 0 do
    GenServer.cast(server, {:change_interval, interval})
  end

  @spec terminate_timer(pid) :: :ok | {:error, :not_found}
  def terminate_timer(pid) do
    DynamicSupervisor.terminate_child(@supervisor, pid)
  end

  @spec stop(GenServer.server()) :: :ok
  def stop(server) do
    GenServer.stop(server)
  end

  ## callbacks

  @impl GenServer
  @spec init({callable, options}) :: {:ok, state, {:continue, atom}}
  def init({callable, opts}) do
    state = %{
      task: normalize_callable(callable),
      interval: opts[:interval],
      timer_ref: nil
    }

    {:ok, state, {:continue, :schedule_tick}}
  end

  @impl GenServer
  def handle_cast({:change_interval, interval}, state) do
    _cancel =
      if timer_ref = state.timer_ref do
        Process.cancel_timer(timer_ref)
      end

    {:noreply, %{state | interval: interval, timer_ref: nil}, {:continue, :schedule_tick}}
  end

  @impl GenServer
  def handle_info(:tick, %{task: task} = state) do
    this = self()

    case Task.Supervisor.start_child(@tasks, fn -> task.(this) end) do
      {:ok, _pid} -> :noop
      {:error, reason} -> Logger.error("failed to trigger task, reason: #{inspect(reason)}")
    end

    {:noreply, %{state | timer_ref: nil}, {:continue, :schedule_tick}}
  end

  @impl GenServer
  @spec handle_continue(:schedule_tick, state) :: {:noreply, state}
  def handle_continue(:schedule_tick, %{timer_ref: nil} = state) do
    timer_ref = Process.send_after(self(), :tick, state.interval)
    {:noreply, %{state | timer_ref: timer_ref}}
  end

  ## priv

  defp normalize_callable(callable) do
    case callable do
      {mod, fun, extra_args} -> capture(mod, fun, List.wrap(extra_args))
      {mod, fun} -> capture(mod, fun, [])
      func when is_function(func, 1) -> func
    end
  end

  defp capture(mod, fun, extra_args) do
    fn pid -> apply(mod, fun, [pid | extra_args]) end
  end
end
