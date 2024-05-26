defmodule Nix.Dev.Run.All do
  @moduledoc false

  alias Nix.Dev.Run.All.MatchTasks

  defdelegate match_tasks(task_list, patterns), to: MatchTasks, as: :run
end
