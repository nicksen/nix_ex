# Nix.Ticker

Register timers that repeatedly triggers a process with a fixed time delay between each trigger.

## Installation

The package can be installed by adding `nix_ticker` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:nix_ticker, github: "nicksen/nix_ex", sparse: "nix_ticker"}
  ]
end
```

## Usage

Include the supervisor in your supervision tree:

```elixir
# lib/my_app/application.ex
def start(_type, _args) do
  children = [
    Nix.Ticker.Supervisor
  ]

  Supervisor.start_link(children, strategy: :one_for_one, name: MyApp.Supervisor)
end
```

Start new timers:

```elixir
# Start timer
callback = fn pid -> IO.puts("called from #{inspect(pid)} @ #{inspect(NaiveDateTime.utc_now())}") end
{:ok, _pid} = Nix.Ticker.start_timer(callback, interval: 10_000)
# => {:ok, #PID<0.153.0>}

# callback can also be defined as mf(a) tuples
defmodule Foo do
  def bar(pid) do
    IO.puts("called from #{inspect(pid)} @ #{inspect(NaiveDateTime.utc_now())}")
  end

  def bar(pid, caller) do
    IO.puts("called from #{inspect(pid)} / started by #{inspect(caller)} @ #{inspect(NaiveDateTime.utc_now())}")
  end
end
{:ok, _pid} = Nix.Ticker.start_timer({Foo, :bar}, interval: 5_000)
# => {:ok, #PID<0.164.0>}

this = self()
# => #PID<0.130.0>
{:ok, _pid} = Nix.Ticker.start_timer({Foo, :bar, [this]}, interval: 10_000)
# => {:ok, #PID<0.169.0>}

# callback called at estimated time
# => called from #PID<0.153.0> @ ~N[2024-05-12 13:34:08]
# => called from #PID<0.164.0> @ ~N[2024-05-12 13:34:12]
# => called from #PID<0.164.0> @ ~N[2024-05-12 13:34:17]
# => called from #PID<0.153.0> @ ~N[2024-05-12 13:34:18]
# => called from #PID<0.169.0> / started by #PID<0.130.0> @ ~N[2024-05-12 13:34:18]
```
