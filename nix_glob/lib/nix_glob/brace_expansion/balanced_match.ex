defmodule Nix.Glob.BraceExpansion.BalancedMatch do
  @moduledoc false

  ## types

  @type t :: %{
          start: non_neg_integer,
          finish: non_neg_integer,
          pre: String.t(),
          body: String.t(),
          post: String.t()
        }

  ## api

  @spec balanced(String.t(), String.t(), String.t()) :: {:ok, t} | :error
  def balanced(str, opener, closer) do
    with {:ok, parsed} <- parse(str, opener, closer) do
      {:ok, format(parsed)}
    end
  end

  ## priv

  defp parse(str, opener, closer) do
    str_len = String.length(str)
    opener_len = String.length(opener)
    closer_len = String.length(closer)

    acc = %{
      str: str,
      opener: opener,
      closer: closer,
      done: false,
      i: 0,
      opener_slice: String.slice(str, 0, opener_len),
      closer_slice: String.slice(str, 0, closer_len),
      str_len: str_len,
      opener_len: opener_len,
      closer_len: closer_len,
      bal: 0,
      start: nil,
      finish: nil,
      segments: %{
        pre: "",
        body: "",
        post: ""
      }
    }

    acc
    |> get_segments()
    |> deal_with_inbalance()
  end

  defp get_segments(%{i: at_end, str_len: at_end} = state) do
    state
  end

  defp deal_with_inbalance(%{bal: bal, done: true} = state) when bal != 0 do
    %{str: str, opener: opener, closer: closer, str_len: str_len, opener_len: opener_len, start: start} = state

    str
    |> String.slice(start + opener_len, str_len)
    |> parse(opener, closer)
    |> reconstitute(str, start + opener_len)
  end

  defp format(%{start: start, finish: finish, segments: %{pre: pre, body: body, post: post}}) do
    %{
      start: start,
      finish: finish,
      pre: pre,
      body: body,
      post: post
    }
  end
end
