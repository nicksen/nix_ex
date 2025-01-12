defmodule Nix.TOTPTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  import Nix.TOTP

  doctest Nix.TOTP, import: true

  describe "otpauth_uri" do
    test "generate a uri without params" do
      secret = Base.decode32!("PTEPUGZ7DUWTBGMW4WLKB6U63MGKKMCA")

      assert otpauth_uri("some_app", secret) ==
               "otpauth://totp/some_app?secret=PTEPUGZ7DUWTBGMW4WLKB6U63MGKKMCA"
    end

    test "generate a uri with custom params" do
      secret = Base.decode32!("PTEPUGZ7DUWTBGMW4WLKB6U63MGKKMCA")
      app = "Issuing service"

      assert otpauth_uri("#{app}:user@example.com", secret, issuer: app) == """
             otpauth://totp/Issuing%20service:user@example.com?\
             secret=PTEPUGZ7DUWTBGMW4WLKB6U63MGKKMCA&\
             issuer=Issuing%20service\
             """
    end
  end

  describe "secret" do
    test "generate a secret with default (20) length" do
      key = secret()
      assert byte_size(key) == 20
    end

    property "always generates a secret of specified length" do
      check all size <- non_negative_integer() do
        key = secret(size)
        assert byte_size(key) == size
      end
    end

    test "always generates a different random secret" do
      n = Enum.random(100..10_000)
      keys = Enum.map(1..n, fn _ -> secret() end)
      assert Enum.uniq(keys) == keys
    end
  end

  describe "verification_code" do
    test "generate 6 digit verification code" do
      ts = System.os_time(:second)

      for _ <- 1..1000 do
        secret = secret()
        assert verification_code(secret, time: ts) =~ ~r/\d{6}/
      end
    end

    test "pad with leading 0s to maintain set length" do
      secret = Base.decode32!("BKFCZBQPZOXNTER5HKHGPHPGCXBNBDNC")
      time = to_unix(~U[2020-04-08 18:09:11Z])

      assert verification_code(secret, time: time) == "005357"
    end

    test "generate unique codes in different time periods (default 30s)" do
      key = secret()

      time1 = ~U[2020-04-08 17:49:59Z]
      time2 = ~U[2020-04-08 17:50:00Z]
      time3 = ~U[2020-04-08 17:50:30Z]

      code1 = verification_code(key, time: time1)
      assert verification_code(key, time: to_unix(time1)) == code1
      code2 = verification_code(key, time: time2)
      assert verification_code(key, time: to_unix(time2)) == code2
      code3 = verification_code(key, time: time3)
      assert verification_code(key, time: to_unix(time3)) == code3

      codes = [code1, code2, code3]
      assert Enum.uniq(codes) == codes
    end

    test "generate same code for the same period" do
      key = secret()
      time1 = to_unix(~U[2020-04-08 17:50:00Z])
      time2 = to_unix(~U[2020-04-08 17:50:14Z])

      code1 = verification_code(key, time: time1, period: 15)
      code2 = verification_code(key, time: time2, period: 15)

      assert code1 == code2
    end
  end

  describe "valid?" do
    test "check that a code is valid" do
      timestamp = DateTime.utc_now(:second)
      naive_ts = DateTime.to_naive(timestamp)
      epoch = DateTime.to_unix(timestamp)

      for _ <- 1..1000 do
        key = secret()

        code = verification_code(key, time: epoch)
        assert verification_code(key, time: timestamp) == code
        assert verification_code(key, time: naive_ts) == code

        assert valid?(key, code, time: epoch)
        assert valid?(key, code, time: timestamp)
        assert valid?(key, code, time: naive_ts)

        refute valid?(key, "abcdef", time: epoch)
        refute valid?(key, "abcdef", time: timestamp)
        refute valid?(key, "abcdef", time: naive_ts)
      end
    end

    test "rejects code reusage" do
      timestamp = DateTime.utc_now(:second)
      epoch = DateTime.to_unix(timestamp)
      next_tick = (Integer.floor_div(epoch, 30) + 1) * 30

      for _ <- 1..1000 do
        key = secret()
        code = verification_code(key, time: epoch)
        next_code = verification_code(key, time: next_tick)

        assert valid?(key, code, time: epoch)
        refute valid?(key, "abcdef", time: epoch)

        # always rejects invalid codes
        refute valid?(key, "abcdef", time: epoch, since: epoch)
        refute valid?(key, "abcdef", time: epoch, since: next_tick)
        refute valid?(key, "abcdef", time: epoch, since: nil)

        # `since: nil` - i.e. first time code is used
        assert valid?(key, code, time: epoch, since: nil)

        # rejects repeat usage
        refute valid?(key, code, time: epoch, since: epoch)

        # the next code is valid
        assert valid?(key, next_code, time: next_tick, since: epoch)
      end
    end

    test "rejects codes without enough digits" do
      timestamp = DateTime.utc_now(:second)
      key = secret()
      code = verification_code(key, time: timestamp)

      refute valid?(key, "", time: timestamp)
      refute valid?(key, binary_part(code, 0, 5), time: timestamp)
      refute valid?(key, <<?0, code::binary>>, time: timestamp)
    end
  end
end
