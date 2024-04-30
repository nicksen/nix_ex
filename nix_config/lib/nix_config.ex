defmodule Nix.Config do
  @moduledoc """
  Utilities to manage runtime configuration.
  """

  ## api

  @doc """
  Retrieves value for environment.
  """
  @spec env_specific(keyword) :: term
  defmacro env_specific(config) do
    quote do
      unquote(Keyword.get_lazy(config, config_env(), fn -> Keyword.get(config, :else) end))
    end
  end

  @doc """
  Similar to `c:env_specific/1` but raises `KeyError` if value could not be extracted.
  """
  @spec env_specific!(keyword) :: term
  defmacro env_specific!(config) do
    quote do
      unquote(
        Keyword.get_lazy(config, config_env(), fn ->
          case Keyword.fetch(config, :else) do
            {:ok, value} ->
              value

            :error ->
              quote do
                raise KeyError, "key :else not found in: #{inspect(unquote(config))}"
              end
          end
        end)
      )
    end
  end

  @spec os_env(name :: String.t(), default :: String.t() | nil) :: String.t() | nil
  def os_env(name, default \\ nil) do
    case System.fetch_env(name) do
      {:ok, value} -> value
      :error -> default
    end
  end

  defdelegate os_env!(name), to: System, as: :fetch_env!

  @spec app_env(path :: [atom], default :: term) :: term
  def app_env(keys, default \\ nil) when is_list(keys) do
    env = Application.get_all_env(otp_app())

    case fetch_app_env(env, keys) do
      {:ok, value} -> value
      :error -> default
    end
  end

  @doc """
  Similar to `c:app_env/2` but raises a `KeyError` if the (nested) env doesn't exist.
  """
  @spec app_env!(path :: [atom]) :: term
  def app_env!(keys) when is_list(keys) do
    env = Application.get_all_env(otp_app())

    case fetch_app_env(env, keys) do
      {:ok, value} -> value
      :error -> raise KeyError, "could not fetch #{inspect(keys)} in #{inspect(env)}"
    end
  end

  @doc """
  Get otp app.
  """
  @spec otp_app() :: atom
  def otp_app, do: Application.fetch_env!(:nix_config, :otp_app)

  @doc """
  Get the current environment.
  """
  @spec config_env() :: atom
  def config_env, do: Application.fetch_env!(:nix_config, :env)

  @doc """
  Deeply merge keyword lists.

  Nested keyword lists are also merged.
  """
  @spec merge(keyword, keyword) :: keyword
  def merge(left, right) when is_list(left) and is_list(right) do
    deep_merge(right, left, [], left, &merger/3)
  end

  @spec merge(nonempty_list(keyword)) :: keyword
  def merge([initial | overrides]) do
    for override <- overrides, reduce: initial do
      current -> merge(current, override)
    end
  end

  ## priv

  defp fetch_app_env(env, []), do: {:ok, env}

  defp fetch_app_env(app, [key | keys]) do
    with {:ok, nested} <- Access.fetch(app, key) do
      fetch_app_env(nested, keys)
    end
  end

  defp deep_merge([], acc, append, _original, _merge_fn) do
    acc ++ Enum.reverse(append)
  end

  defp deep_merge([{key, right} = item | tail], acc, append, original, merge_fn) do
    case List.keyfind(original, key, 0) do
      {^key, left} ->
        new_acc = List.keystore(acc, key, 0, {key, merge_fn.(key, left, right)})
        new_original = List.keydelete(original, key, 0)
        deep_merge(tail, new_acc, append, new_original, merge_fn)

      _else ->
        new_append = [item | append]
        deep_merge(tail, acc, new_append, original, merge_fn)
    end
  end

  defp merger(_key, left, right) do
    if Keyword.keyword?(left) and Keyword.keyword?(right) do
      merge(left, right)
    else
      right
    end
  end
end
