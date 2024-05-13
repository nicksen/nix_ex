defmodule Nix.Ticker.TimerTest do
  use Nix.TickerCase, async: true

  alias Nix.Ticker.Timer

  @moduletag timeout: 3000

  @interval 30
  @wait_timeout @interval * 3
  @delta_ratio 70..130

  describe "Nix.Ticker.Timer" do
    test "task is called with the timer pid" do
      this = self()
      callback = fn pid -> send(this, pid) end
      timer = supervise!(callback)

      assert_receive ^timer, @wait_timeout
    end

    test "periodic callback" do
      _timer = supervise!()

      assert_receive ts1, @wait_timeout
      assert_receive ts2, @wait_timeout
      assert_receive ts3, @wait_timeout

      delta1 = ts2 - ts1
      delta2 = ts3 - ts2

      assert div(delta1 * 100, @interval) in @delta_ratio
      assert div(delta2 * 100, @interval) in @delta_ratio
    end

    test "periodic callback using mfa", %{test: mod} do
      defmodule mod do
        def run(_pid, manager) do
          send(manager, System.system_time(:millisecond))
        end
      end

      _timer = supervise!({mod, :run, [self()]})

      assert_receive ts1, @wait_timeout
      assert_receive ts2, @wait_timeout
      assert_receive ts3, @wait_timeout

      delta1 = ts2 - ts1
      delta2 = ts3 - ts2

      assert div(delta1 * 100, @interval) in @delta_ratio
      assert div(delta2 * 100, @interval) in @delta_ratio
    end

    test "periodic callback with slow callback" do
      this = self()

      callback = fn _pid ->
        :timer.sleep(@interval)
        send(this, System.system_time(:millisecond))
      end

      _timer = supervise!(callback)

      assert_receive ts1, @wait_timeout
      assert_receive ts2, @wait_timeout
      assert_receive ts3, @wait_timeout

      delta1 = ts2 - ts1
      delta2 = ts3 - ts2

      assert div(delta1 * 100, @interval) in @delta_ratio
      assert div(delta2 * 100, @interval) in @delta_ratio
    end

    @tag :capture_log
    test "periodic callback with failing callback" do
      this = self()

      callback = fn _pid ->
        send(this, System.system_time(:millisecond))
        raise "fail"
      end

      _timer = supervise!(callback)

      assert_receive ts1, @wait_timeout
      assert_receive ts2, @wait_timeout
      assert_receive ts3, @wait_timeout

      delta1 = ts2 - ts1
      delta2 = ts3 - ts2

      assert div(delta1 * 100, @interval) in @delta_ratio
      assert div(delta2 * 100, @interval) in @delta_ratio
    end

    test "stop timer" do
      {:ok, timer} = start()
      assert_receive _ts, @wait_timeout

      :ok = Timer.stop(timer)
      refute_receive _ts, @wait_timeout
    end

    test "change interval" do
      timer = supervise!()

      assert_receive ts1, @wait_timeout
      assert_receive ts2, @wait_timeout

      :ok = Timer.change_interval(timer, @interval * 3)

      assert_receive ts3, @wait_timeout * 3

      delta1 = ts2 - ts1
      delta2 = ts3 - ts2

      assert div(delta1 * 100, @interval) in @delta_ratio
      assert div(delta2 * 100, @interval * 3) in @delta_ratio
    end
  end
end
