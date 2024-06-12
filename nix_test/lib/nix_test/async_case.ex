defmodule Nix.Test.AsyncCase do
  @moduledoc false

  import ExUnit.Assertions

  require ExUnit.Assertions

  ## types

  @type supervisor :: Supervisor.supervisor()

  ## api

  @doc """
  Test helper that waits for tasks started under the test supervisor.

  Will wait for everything started using `ExUnit.Callbacks.start_supervised/2` and its
  counterparts.

  Returns `:error` if not called from a test process.
  """
  @spec flush_task_supervisor() :: :ok | :error
  def flush_task_supervisor do
    with {:ok, supervisor} <- ExUnit.fetch_test_supervisor() do
      flush_task_supervisor(supervisor)
    end
  end

  @doc """
  Test helper that waits for all processes started under `supervisor` to complete.
  """
  @spec flush_task_supervisor(supervisor) :: :ok
  def flush_task_supervisor(supervisor) do
    pids = Task.Supervisor.children(supervisor)

    _down_events =
      for pid <- pids do
        ref = Process.monitor(pid)
        assert_receive {:DOWN, ^ref, _process, _pid, _reason}
      end

    :ok
  end
end
