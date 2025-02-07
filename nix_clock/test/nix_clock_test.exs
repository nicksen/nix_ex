defmodule Nix.ClockTest do
  use ExUnit.Case, async: true

  doctest Nix.Clock, import: true, except: [now: 0, now: 1]
end
