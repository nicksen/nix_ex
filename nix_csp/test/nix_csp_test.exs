defmodule Nix.CSPTest do
  use ExUnit.Case, async: true

  import Plug.Conn
  import Plug.Test

  alias Nix.CSP

  describe "put_content_security_policy" do
    setup do
      {:ok, conn: conn(:get, "/")}
    end

    test "sets default header", %{conn: conn} do
      conn = CSP.put_content_security_policy(conn, [])
      assert csp_header(conn) == ["default-src 'self';"]
    end

    test "with options", %{conn: conn} do
      conn = CSP.put_content_security_policy(conn, img_src: "'self' data:")
      assert csp_header(conn) == ["default-src 'self';img-src 'self' data:;"]
    end

    test "with list of sources", %{conn: conn} do
      conn = CSP.put_content_security_policy(conn, default_src: ["'self'", "data:"])
      assert csp_header(conn) == ["default-src 'self' data:;"]
    end

    test "with duplicate directives", %{conn: conn} do
      conn = CSP.put_content_security_policy(conn, default_src: "'self'", default_src: "data:")
      assert csp_header(conn) == ["default-src 'self' data:;"]
    end

    test "with duplicate sources", %{conn: conn} do
      conn =
        CSP.put_content_security_policy(conn,
          default_src: ["'self'", "data:"],
          default_src: "data:"
        )

      assert csp_header(conn) == ["default-src 'self' data:;"]
    end

    test "with nonce", %{conn: conn} do
      conn = CSP.put_content_security_policy(conn, default_src: "'self' 'nonce'")
      assert ["default-src 'self' 'nonce-" <> _nonce] = csp_header(conn)
    end

    test "with function", %{conn: conn} do
      conn = CSP.put_content_security_policy(conn, &[default_src: &1.host])
      assert csp_header(conn) == ["default-src #{conn.host};"]
    end

    defp csp_header(conn) do
      get_resp_header(conn, "content-security-policy")
    end
  end

  describe "get_csp_nonce" do
    test "token has no padding" do
      refute CSP.get_csp_nonce() =~ "="
    end

    test "token is stored" do
      assert CSP.get_csp_nonce() == CSP.get_csp_nonce()
    end

    test "refresh token" do
      token = CSP.get_csp_nonce()
      CSP.clear_nonce()

      assert token != CSP.get_csp_nonce()
    end

    test "token has variable length" do
      tok1 = CSP.get_csp_nonce(iv_size: 10, regenerate: true)
      tok2 = CSP.get_csp_nonce(iv_size: 20, regenerate: true)

      assert String.length(tok1) < String.length(tok2)
    end
  end
end
