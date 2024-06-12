defmodule Nix.Test.AsyncCaseTest do
  use ExUnit.Case, async: true

  import Nix.Test.AsyncCase

  describe "flush_task_supervisor/1" do
    setup do
      supervisor = Nix.Test.AsyncCaseTest.TaskSupervisor
      _pid = start_link_supervised!({Task.Supervisor, name: supervisor})

      {:ok, supervisor: supervisor}
    end

    test "waits for processes to complete", %{supervisor: supervisor} do
      fun = fn -> Process.sleep(10) end

      assert {:ok, _task} = Task.Supervisor.start_child(supervisor, fun)
      assert :ok = flush_task_supervisor(supervisor)
    end

    test "flunks test if process doesn't complete in time", %{supervisor: supervisor} do
      fun = fn -> Process.sleep(300) end

      assert {:ok, _task} = Task.Supervisor.start_child(supervisor, fun)

      assert_raise ExUnit.AssertionError, fn ->
        flush_task_supervisor(supervisor)
      end
    end
  end

  describe "flush_task_supervisor/0" do
    test "waits for test child processes to complete" do
      fun = fn -> Process.sleep(10) end
      proc = {Task, fun}

      assert {:ok, _task} = start_supervised(proc)
      assert :ok = flush_task_supervisor()
    end

    test "flunks test if process doesn't complete in time" do
      fun = fn -> Process.sleep(300) end
      proc = {Task, fun}

      assert {:ok, _task} = start_supervised(proc)

      assert_raise ExUnit.AssertionError, fn ->
        flush_task_supervisor()
      end
    end
  end
end
