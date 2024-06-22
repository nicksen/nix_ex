import Config

if config_env() == :test do
  echo = Path.expand("../test/support/echo.js", __DIR__)

  config :nix_dev,
    script: [
      args: [echo]
    ],
    npm_cmd: [
      args: ["whoami"]
    ],
    npx_cmd: [
      args: ~w(prettier --help)
    ]
end
