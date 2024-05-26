defmodule Mix.Tasks.TestTask do
  @moduledoc false

  defmodule One do
    @moduledoc nil

    use Mix.Task

    @impl Mix.Task
    def run(_args) do
      :ok
    end
  end

  defmodule Two do
    @moduledoc nil

    use Mix.Task

    @impl Mix.Task
    def run(_args) do
      :ok
    end
  end
end
