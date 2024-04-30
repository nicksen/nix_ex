defmodule Nix.ConfigCase do
  @moduledoc false

  use ExUnit.CaseTemplate

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
      reset =
        for {key, val} <- tags[:setenv] do
          env = to_string(key)
          curval = System.get_env(env)

          if val != nil do
            System.put_env(env, val)
          else
            System.delete_env(env)
          end

          {env, curval}
        end

      on_exit(fn -> System.put_env(reset) end)
    end

    :ok
  end
end
