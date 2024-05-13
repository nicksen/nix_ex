defmodule Nix.CSP do
  @moduledoc """
  Module that includes `plug` and `phoenix_live_view` helpers to handle
  [Content-Security-Policy](https://developer.mozilla.org/en-US/docs/Web/HTTP/CSP) headers.

  For inline `<style>` and `<script>` tags, nonce should be used. When the HTTP request is
  processed, a nonce is added to the process dictionary. This ensures the nonce stays the same
  throughout the call, as the nonce in the tags must match the nonce in the header.

  To allow for inline `<style>` and/or `<script>` tags, you must set a `'nonce'` source.

  ## Set up

  To set up `#{inspect(__MODULE__)}` in your app:

  ### 1. Configure imports

  Ensure you import the helpers:

  ```elixir
  def router do
    quote do
      use Phoenix.Router, helpers: false

      # Import common connection and controller functions to use in pipelines
      import Phoenix.Controller
      import Phoenix.LiveView.Router
      import Plug.Conn

      import #{inspect(__MODULE__)}, only: [put_content_security_policy: 2] # <-- add
    end
  end

  # ...

  def html do
    quote do
      use Phoenix.Component

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, view_module: 1, view_template: 1]

      import #{inspect(__MODULE__)}, only: [get_csp_nonce: 0] # <-- add

      # Include general helpers for rendering HTML
      unquote(html_helpers())
    end
  end

  # ...

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {YourAppWeb.Layouts, :app}

      on_mount #{inspect(__MODULE__)} # <-- add

      unquote(html_helpers())
    end
  end
  ```

  ### 2. Add nonce metatag to the HTML document

  Add the following metatag to the `<head>` in your root layout:

  ```heex
  <meta name="csp-nonce" content={get_csp_nonce()} />
  ```

  ### 3. Pass the CSP nonce to the liveview socket

  Pass the nonce to the `LiveView` socket in `assets/js/app.js`:

  ```js
  const csrfToken = document.querySelector(`meta[name="csrf-token"]`)?.getAttribute(`content`)
  const cspNonce = document.querySelector(`meta[name="csp-nonce"]`)?.getAttribute(`content`)
  const liveSocket = new LiveSocket(`/live`, Socket, {
    longPollFallbackMs: 2500,
    params: { _csrf_token: csrfToken, _csp_nonce: cspNonce }
  })
  ```

  ### Usage

  If you got inline `<style>` or `<script>` tags, you must set the `nonce` attribute:

  ```heex
  <style nonce={get_csp_nonce()}>
    // ...
  </style>
  ```
  """

  import Plug.Conn

  require Logger

  @default_csp_size 24

  ## types

  @type conn :: Plug.Conn.t()

  ## api

  @doc """
  Set a Content-Security-Policy header.

  By default the policy is `default-src 'self'`, `'nonce'` source will be expanded with an
  auto-generated nonce that is persisted in the process dictionary.

  The options can be a function or a keyword list. Sources can be a binary or list of binaries.
  Duplicate directives will be merged together.

  ## Example

      plug :put_content_security_policy,
        img_src: "'self' data:",
        style_src: "'self' 'nonce'"

      plug :put_content_security_policy,
        img_src: ["'self'", "data:"]

      plug :put_content_security_policy, &YourAppWeb.CSPPolicy.opts/1
  """
  @spec put_content_security_policy(conn, keyword | opts_fun) :: conn
        when opts_fun: (conn -> keyword)
  def put_content_security_policy(conn, opts_or_fun)

  def put_content_security_policy(conn, fun) when is_function(fun, 1) do
    put_content_security_policy(conn, fun.(conn))
  end

  def put_content_security_policy(conn, opts) when is_list(opts) do
    csp =
      opts
      |> maybe_prepend_default_src()
      |> Enum.reduce([], fn {name, sources}, acc ->
        sources = List.wrap(sources)
        Keyword.update(acc, name, sources, &(&1 ++ sources))
      end)
      |> Enum.reduce("", fn {name, sources}, acc ->
        directive =
          name
          |> Atom.to_string()
          |> String.replace("_", "-")

        sources =
          sources
          |> Enum.uniq()
          |> Enum.join(" ")
          |> String.replace("'nonce'", "'nonce-#{get_csp_nonce(opts)}'")

        "#{acc}#{directive} #{sources};"
      end)

    put_resp_header(conn, "content-security-policy", csp)
  end

  @doc """
  Get the CSP nonce.

  Generates a nonce and stores it in the process dictionary if it doesn't exist.

  ## Options

    * `:iv_size` - how many random bytes to generate (default 24).
    * `:regenerate` - use to force a new nonce (default false).
  """
  @spec get_csp_nonce(keyword) :: String.t()
  def get_csp_nonce(opts \\ []) do
    if nonce = !opts[:regenerate] && Process.get(:plug_csp_nonce) do
      nonce
    else
      nonce =
        opts
        |> Keyword.get(:iv_size, @default_csp_size)
        |> gen_csp_nonce()

      Process.put(:plug_csp_nonce, nonce)

      nonce
    end
  end

  @doc """
  Clear the stored nonce.
  """
  @spec clear_nonce() :: :ok
  def clear_nonce do
    Process.delete(:plug_csp_nonce)
    :ok
  end

  @doc false
  @spec on_mount(atom, map, map, socket) :: {:cont, socket} when socket: term
  def on_mount(name, params, session, socket)

  def on_mount(:default, _params, _session, %{private: %{connect_params: %{"_csp_nonce" => nonce}}} = socket) do
    Process.put(:plug_csp_nonce, nonce)
    {:cont, socket}
  end

  def on_mount(:default, _params, _session, socket) do
    unless Process.get(:plug_csp_nonce) do
      Logger.debug("""
      LiveView session is misconfigured.

      1) Ensure the `put_content_security_policy` plug is in your router pipeline:

          plug :put_content_security_policy

      2) Define the CSP meta tag inside the `<head>` tag in your layout:

          <meta name="csp-nonce" content={#{inspect(__MODULE__)}.get_csp_nonce()} />

      3) Pass it forward in your app.js:

          let cspNonce = document.querySelector("meta[name='csp-nonce']").getAttribute("content")
          let liveSocket = new LiveSocket("/live", Socket, {params: {_csp_nonce: cspNonce}})
      """)
    end

    {:cont, socket}
  end

  ## priv

  defp maybe_prepend_default_src(opts) do
    if Keyword.has_key?(opts, :default_src) do
      opts
    else
      [{:default_src, "'self'"} | opts]
    end
  end

  defp gen_csp_nonce(n) do
    bin = :crypto.strong_rand_bytes(n)
    Base.encode64(bin, padding: false)
  end
end
