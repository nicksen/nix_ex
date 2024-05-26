defmodule Mix.Tasks.Run.AllTest do
  use ExUnit.Case, async: true

  import ExUnit.CaptureIO

  test "" do
    out = capture_io(fn -> Mix.Task.run("run.all", ["test_task.*", "--list"]) end)
    assert out =~ "test_task.one"
    assert out =~ "test_task.two"
  end
end
