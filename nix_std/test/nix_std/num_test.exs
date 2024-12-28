defmodule Nix.Std.NumTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias Nix.Std.Num

  @moduletag :f

  doctest Num, import: true

  describe "Num.clamp" do
  end
end
