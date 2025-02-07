defmodule Nix.Clock do
  @moduledoc """
  Collection of functions for dealing with the current time.

  When testing time-dependent functionality, this module allows you to "freeze" the current time
  at specific moments and simulate the passing of time.
  """

  @conf Application.compile_env(:nix_clock, __MODULE__, [])

  ## types

  @type timestamp :: integer
  @type unit :: :erlang.time_unit()

  ## api

  @doc """
  """
  @spec now() :: timestamp
  def now, do: now(:native)

  @doc """
  """
  @spec now(unit) :: timestamp
  def now(unit), do: if(ts = get_state(), do: conv(ts, :native, unit), else: System.os_time(unit))

  @doc """
  """
  @spec current_time() :: timestamp
  def current_time, do: now(:second)

  @doc """
  """
  @spec freeze() :: :ok
  def freeze, do: freeze(now())

  @doc """
  """
  @spec freeze(timestamp) :: :ok
  def freeze(timestamp), do: set_state(timestamp)

  @doc """
  """
  @spec unfreeze() :: :ok
  def unfreeze, do: set_state(nil)

  ## priv

  defp get_state, do: Agent.get(__MODULE__, &Function.identity/1)

  defp set_state(state), do: Agent.update(__MODULE__, fn _prev_state -> state end)
end
