defmodule Nix.Dev.Application do
  @moduledoc false

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  use Application

  @impl Application
  def start(_type, _args) do
    children = []

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one]
    Supervisor.start_link(children, opts)
  end
end
