defmodule Nix.Dev.Run.AllTest do
  use ExUnit.Case, async: true

  import MatchTasksAssertions

  describe "match_tasks" do
    test "expand wildcard" do
      assert_tasks "append.*" == ["append.a", "append.b"]
    end

    test "expands rest with globstar" do
      assert_tasks "append.**.*" == ["append.a", "append.a.c", "append.a.d", "append.b"]
    end

    test "ignore duplicate matches" do
      assert_tasks ["append.b", "append.*"] == ["append.b", "append.a"]
    end

    test "expanding wildcard properly filters by prefix" do
      assert_tasks "a" == []
    end

    test "exclude from start should not match anything" do
      assert_tasks "!append:**" == []
    end

    test "match exact task name" do
      assert_tasks ["!test", "?test"] == ["!test", "?test"]
    end

    @tag :skip
    test "exclude task from wildcard" do
      assert_tasks "append.*(!a)" == ["append.b"]
    end

    @tag :skip
    test "exclude task from globstar expansion" do
      assert_tasks "append.**(!c)" == ["append.a", "append.a.d", "append.b"]
    end
  end
end
