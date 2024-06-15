defmodule Nix.Config do
  @moduledoc """
  Utilities to manage runtime configuration.
  """

  ## types

  @type env :: atom

  @type key :: atom
  @type value :: term

  ## api

  @doc """
  Retrieves value for environment or nil if not set.
  """
  @spec env_specific([{env, value} | {:else, value}]) :: value
  defmacro env_specific(config) do
    quote do
      unquote(Keyword.get_lazy(config, config_env(), fn -> Keyword.get(config, :else) end))
    end
  end

  @doc """
  Retrieves value for environment or raises if not set.

  Same as `env_specific/1` but raises instead of returning `nil` if not found.
  """
  @spec env_specific!([{env, value} | {:else, value}]) :: value
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

  @doc """
  Returns the value of the given environment variable.

  The returned value is a string. If the variable is not set, returns the string specified in
  `default` (`nil` by default).
  """
  @spec os_env(String.t(), String.t()) :: String.t()
  @spec os_env(String.t(), nil) :: String.t() | nil
  def os_env(name, default \\ nil) do
    case fetch_os_env(name) do
      {:ok, value} -> value
      :error -> default
    end
  end

  @doc """
  Returns the value of the given environment variable or raises if not found.

  Same as `os_env/1` but raises instead of returning some default when the variable is not set.
  """
  @spec os_env!(String.t()) :: String.t()
  defdelegate os_env!(name), to: System, as: :fetch_env!

  @doc """
  Returns the value of the given environment variable or `:error` if nout found.

  If the environment variable `name` is set, then `{:ok, value}` is returned where `value` is a
  string. If `name` is not set `:error` is returned.
  """
  @spec fetch_os_env(String.t()) :: {:ok, String.t()} | :error
  defdelegate fetch_os_env(name), to: System, as: :fetch_env

  @doc """
  Returns the value given by `path` from the application environment.

  If the value doesn't exist, returns the `default` value (`nil` by default).
  """
  @spec app_env([key], value) :: value
  def app_env(path, default \\ nil) when is_list(path) do
    env = Application.get_all_env(otp_app())

    case fetch_app_env(env, path) do
      {:ok, value} -> value
      :error -> default
    end
  end

  @doc """
  Returns the value given by `path` from the application environment.

  Same as `app_env/1` but raises if the value doesn't exist.
  """
  @spec app_env!([key]) :: value
  def app_env!(path) when is_list(path) do
    env = Application.get_all_env(otp_app())

    case fetch_app_env(env, path) do
      {:ok, value} -> value
      :error -> raise KeyError, "could not fetch #{inspect(path)} in #{inspect(env)}"
    end
  end

  @doc """
  Get the configured otp app.
  """
  @spec otp_app() :: Application.app()
  def otp_app, do: Application.fetch_env!(:nix_config, :otp_app)

  @doc """
  Get the configured environment.
  """
  @spec config_env() :: env
  def config_env, do: Application.fetch_env!(:nix_config, :env)

  @doc """
  Recursively merge a list of keyword lists.
  """
  @spec merge([keyword, ...]) :: keyword
  def merge([initial | overrides]) do
    for override <- overrides, reduce: initial do
      current -> merge(current, override)
    end
  end

  @doc """
  Recursively merge two keyword lists.
  """
  @spec merge(map, map) :: map
  @spec merge(keyword, keyword) :: keyword
  defdelegate merge(left, right), to: Nix.DeepMerge

  ## priv

  defp fetch_app_env(env, []), do: {:ok, env}

  defp fetch_app_env(app, [key | keys]) do
    with {:ok, nested} <- Access.fetch(app, key) do
      fetch_app_env(nested, keys)
    end
  end
end
