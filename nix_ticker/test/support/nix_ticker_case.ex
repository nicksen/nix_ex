defmodule Nix.TickerCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Nix.Ticker.Timer

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  setup do
    ticker_pid = start_link_supervised!(Nix.Ticker.Supervisor)
    {:ok, ticker_pid: ticker_pid}
  end

  def register_timer do
    register_timer(callable(self()), [])
  end

  def register_timer(opts) when is_list(opts) do
    register_timer(callable(self()), opts)
  end

  def register_timer(callback) do
    register_timer(callback, [])
  end

  def register_timer(callback, opts) do
    Nix.Ticker.start_timer(callback, opts)
  end

  def supervise! do
    supervise!(callable(self()), [])
  end

  def supervise!(opts) when is_list(opts) do
    supervise!(callable(self()), opts)
  end

  def supervise!(callback) do
    supervise!(callback, [])
  end

  def supervise!(callback, opts) do
    timer_opts = Keyword.validate!(opts, interval: 30)
    start_link_supervised!({Timer, {callback, timer_opts}})
  end

  def start do
    start(callable(self()), [])
  end

  def start(opts) when is_list(opts) do
    start(callable(self()), opts)
  end

  def start(callback) do
    start(callback, [])
  end

  def start(callback, opts) do
    timer_opts = Keyword.validate!(opts, interval: 30)
    Timer.start_link({callback, timer_opts})
  end

  def callable(notify_pid) do
    fn _pid -> send(notify_pid, System.monotonic_time(:millisecond)) end
  end
end
