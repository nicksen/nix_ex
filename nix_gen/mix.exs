defmodule NixGen.MixProject do
  use Mix.Project

  @vsn "1.0.0"

  def project do
    [
      app: :nix_gen,
      version: @vsn,
      elixir: "~> 1.16",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      dialyzer: dialyzer()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # specifies which paths to compile per environment
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      ## dev
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:credo_contrib, "~> 0.2", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:markdown_formatter, "~> 0.6", only: [:dev, :test], runtime: false},
      {:mix_audit, "~> 2.1", only: [:dev, :test], runtime: false},
      {:recode, "~> 0.7", only: [:dev, :test], runtime: false},
      {:styler, "~> 0.11", only: [:dev, :test], runtime: false}
    ]
  end

  # aliases are shortcuts or tasks specific to the current project
  # see the documentation for `mix` for more info on aliases
  defp aliases do
    [
      fmt: [
        "do deps.unlock --unused + deps.clean --unused",
        "format",
        "cmd mix recode --autocorrect"
      ],
      lint: [
        "compile --all-warnings --warnings-as-errors",
        "xref graph --label compile-connected --fail-above 0",
        "deps.unlock --check-unused",
        "format --check-formatted",
        "cmd mix recode",
        "cmd mix hex.audit",
        "deps.audit",
        "credo suggest",
        "dialyzer"
      ]
    ]
  end

  defp dialyzer do
    [
      flags: [
        :error_handling,
        :no_undefined_callbacks,
        :underspecs,
        :unknown,
        :unmatched_returns
      ],
      plt_add_apps: [:mix],
      ignore_warnings: ".dialyzer_ignore.exs",
      list_unused_filters: true,
      plt_core_path: "../.cache/plts",
      plt_local_path: ".cache/plts"
    ]
  end
end
