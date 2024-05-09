defmodule Nix.Ticker.Supervisor do
  @moduledoc false

  use Supervisor

  ## api

  @doc false
  @spec start_link(any) :: Supervisor.on_start()
  def start_link(init_args) do
    Supervisor.start_link(__MODULE__, init_args, name: __MODULE__)
  end

  ## callbacks

  @impl Supervisor
  @spec init(any) :: {:ok, {Supervisor.sup_flags(), [Supervisor.child_spec()]}}
  def init(_init_args) do
    children = [
      {DynamicSupervisor, strategy: :one_for_one, name: Nix.Ticker.TimerSupervisor},
      {Task.Supervisor, name: Nix.Ticker.TaskSupervisor}
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end
end
