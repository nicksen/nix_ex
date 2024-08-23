defmodule Nix.ConfigCase do
  @moduledoc false

  use ExUnit.CaseTemplate

  alias Nix.Std.Lazy

  using do
    quote do
      import unquote(__MODULE__)
    end
  end

  setup tags do
    __MODULE__.setup_env(tags)
  end

  def setup_env(tags) do
    if tags[:app_env] do
      current_env = Application.get_all_env(:nix_config)

      Application.put_all_env([
        {:nix_config, [otp_app: tags[:test]]},
        {tags[:test], tags[:app_env]}
      ])

      on_exit(fn ->
        Application.put_all_env([{:nix_config, current_env}, {tags[:test], []}])
      end)
    end

    if tags[:setenv] do
      :ok =
        tags[:setenv]
        |> readenv()
        |> Lazy.bind(&setenv/1)
        |> on_exit()

      :ok = setenv(tags[:setenv])
    end

    :ok
  end

  defp setenv(enum), do: System.put_env(enum)

  defp readenv(enum) do
    full_env = System.get_env()

    for {key, _val} <- enum do
      name = to_string(key)

      case Map.fetch(full_env, name) do
        {:ok, cur} -> {key, cur}
        :error -> {key, nil}
      end
    end
  end
end
