defmodule Nix.TickerTest do
  use Nix.TickerCase, async: false

  @moduletag timeout: 3000
  @moduletag :capture_log

  describe "Nix.Ticker" do
    test "lists timers" do
      {:ok, _pid} = register_timer(interval: 3000)
      {:ok, _pid} = register_timer(interval: 5000)

      assert length(Nix.Ticker.list()) == 2
    end

    test "terminate timer" do
      {:ok, pid1} = register_timer(interval: 3000)
      {:ok, pid2} = register_timer(interval: 5000)

      Nix.Ticker.terminate(pid1)

      assert Nix.Ticker.list() == [pid2]
    end

    test "change interval" do
      this = self()
      {:ok, timer} = register_timer(fn _pid -> send(this, :tick) end, interval: 100)

      :ok = Nix.Ticker.change_interval(timer, 10)

      assert_receive :tick, 50
    end
  end
end
