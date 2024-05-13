defmodule Nix.Ticker.Timer.State do
  @moduledoc false

  ## struct

  @enforce_keys [:task, :interval]
  defstruct [:task, :interval, :timer_ref]

  ## types

  @type t :: %__MODULE__{
          task: (pid -> any),
          interval: pos_integer,
          timer_ref: reference | nil
        }

  ## api

  @doc """
  Creates new state.
  """
  @spec new(keyword) :: t
  def new(opts) do
    struct!(__MODULE__, opts)
  end

  @doc """
  Modify `state` with `updates`.
  """
  @spec update(t, keyword) :: t
  def update(state, updates) do
    struct!(state, updates)
  end
end
