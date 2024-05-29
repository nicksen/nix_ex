defmodule Nix.Glob.BraceExpansion do
  @moduledoc """
  Perform shell
  [brace expansion](https://www.gnu.org/software/bash/manual/html_node/Brace-Expansion.html).
  """

  import DocExample

  @esc_slash "\0SLASH#{:rand.uniform()}\0"
  @esc_open "\0OPEN#{:rand.uniform()}\0"
  @esc_close "\0CLOSE#{:rand.uniform()}\0"
  @esc_comma "\0COMMA#{:rand.uniform()}\0"
  @esc_dot "\0DOT#{:rand.uniform()}\0"

  @doc """
  Expands the string into a list of patterns.

  ## Examples

  #{ex(["file-a.jpg", "file-b.jpg", "file-c.jpg"]) do
    expand("file-{a,b,c}.jpg")
  end}

  #{ex(["-v", "-v", "-v"]) do
    expand("-v{,,}")
  end}

  #{ex(["file0.jpg", "file1.jpg", "file2.jpg"]) do
    expand("file{0..2}.jpg")
  end}

  #{ex(["file-a.jpg", "file-b.jpg", "file-c.jpg"]) do
    expand("file{a..c}.jpg")
  end}

  #{ex(["file2.jpg", "file1.jpg", "file0.jpg"]) do
    expand("file{2..0}.jpg")
  end}

  #{ex(["file0.jpg", "file2.jpg", "file4.jpg"]) do
    expand("file{0..4..2}.jpg")
  end}

  #{ex(["file-a.jpg", "file-c.jpg", "file-e.jpg"]) do
    expand("file{a..e..2}.jpg")
  end}

  #{ex(["file00.jpg", "file05.jpg", "file10.jpg"]) do
    expand("file{00..10..5}.jpg")
  end}

  #{ex(["A", "B", "C", "a", "b", "c"]) do
    expand("{{A..C},{a..c}}")
  end}

  #{ex(["ppp", "pppconfig", "pppoe", "pppoeconf"]) do
    expand("ppp{,config,oe{,conf}}")
  end}
  """
  @spec expand(String.t()) :: [String.t()]
  def expand(str) do
    str
    |> escape_braces()
    |> expand_braces(true)
    |> Enum.map(&unescape_braces/1)
  end

  ## priv

  defp expand_braces(str, first?) do
  end

  defp escape_braces(str) do
    str
    |> split_join("\\\\", @esc_slash)
    |> split_join("\\{", @esc_open)
    |> split_join("\\}", @esc_close)
    |> split_join("\\,", @esc_comma)
    |> split_join("\\.", @esc_dot)
  end

  defp unescape_braces(str) do
    str
    |> split_join(@esc_slash, "\\")
    |> split_join(@esc_open, "{")
    |> split_join(@esc_close, "}")
    |> split_join(@esc_comma, ",")
    |> split_join(@esc_dot, ".")
  end

  defp split_join(str, splitter, joiner) do
    str
    |> String.split(splitter)
    |> Enum.join(joiner)
  end
end
