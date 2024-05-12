defprotocol Nix.DeepMerge.Resolver do
  @moduledoc """
  Protocol defining how to resolve conflicts when merging.

  Provides implementations for `Map`, `List`, as well as a fallback to `Any` (which just uses
  the override).

  If you want your structs to be mergable, and not just override one another (default behaviour)
  , you can derive the protocol:

      defmodule MyStruct do
        @derive [#{inspect(__MODULE__)}]
        defstruct [:attr]
      end

  You can now automatically merge structs of its own kind, but not with other structs or maps.
  """

  @fallback_to_any true

  @doc """
  Defines what happens when a merge conflict occurs on this struct during a merge.

  Can be implemented for additional data types to provide custom deep merging behaviour.

  The passed in values are:
  * `original` - the value in the original data structure, usually left side argument.
  * `override` - the value with which `original` would be overridden in a normal `Map.merge/2`.
  * `resolver` - the function used to resolve merge conflicts, i.e. what you can pass to
    `Map.merge/3` or `Keyword.merge/3` to continue merging.

  ## Examples

      defimpl #{inspect(__MODULE__)}, for: MyStruct do
        def resolve(original, %MyStruct{} = override, resolver) do
          valid_override =
            override
            |> Map.from_struct()
            |> Enum.reject(fn {_key, value} -> value == nil end)
            |> Map.new()

          Map.merge(original, valid_override, resolver)
        end

        def resolve(original, override, resolver) when is_map(override) do
          Map.merge(original, override, resolver)
        end
      end
  """
  @spec resolve(collection, collection, (term, value, value -> value)) :: collection
        when collection: term, value: term
  def resolve(original, override, resolver)
end

defimpl Nix.DeepMerge.Resolver, for: Map do
  @doc """
  Resolve the merge between 2 maps by continuing to deep merge them.

  Don't merge structs or if its any other type, take the override value.
  """
  def resolve(original, override, resolver) when is_map(override) and not is_struct(override) do
    Map.merge(original, override, resolver)
  end

  def resolve(_original, override, _resolver) do
    override
  end
end

defimpl Nix.DeepMerge.Resolver, for: List do
  @doc """
  Deep merge keyword lists but avoid overriding keywords with an empty list.
  """
  def resolve([{_k, _v} | _] = original, [{_, _} | _] = override, resolver) do
    keyword_merge(override, original, [], original, resolver)
  end

  def resolve([{_k, _v} | _rest] = original, [], _resolver) do
    original
  end

  def resolve(_original, override, _resolver) do
    override
  end

  ## priv

  defp keyword_merge([], acc, append, _original, _resolver) do
    acc ++ Enum.reverse(append)
  end

  defp keyword_merge([{key, right} = item | rest], acc, append, original, resolver) do
    case List.keyfind(original, key, 0) do
      {^key, left} ->
        acc = List.keystore(acc, key, 0, {key, resolver.(key, left, right)})
        original = List.keydelete(original, key, 0)
        keyword_merge(rest, acc, append, original, resolver)

      _else ->
        append = [item | append]
        keyword_merge(rest, acc, append, original, resolver)
    end
  end
end

defimpl Nix.DeepMerge.Resolver, for: Any do
  defmacro __deriving__(module, struct, opts) do
    quote bind_quoted: [module: module, struct: Macro.escape(struct), opts: opts] do
      defimpl Nix.DeepMerge.Resolver, for: module do
        def resolve(%module{} = original, %module{} = override, resolver) do
          Map.merge(original, override, resolver)
        end

        def resolve(_original, override, _resolver) do
          override
        end
      end
    end
  end

  @doc """
  Fallback that always uses the override.
  """
  def resolve(_original, override, _resolver) do
    override
  end
end
