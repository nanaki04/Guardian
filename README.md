# Guardian

Guardian is an application for adding supervision with state recovery backup to
GenServers with a simple use declaration.

Simply add:

```
use Guardian.Secret
```

instead of use GenServer to your servers, and the supervision and state backup
will be implemented automatically.

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `guardian` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [{:guardian, "~> 0.1.0"}]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at [https://hexdocs.pm/guardian](https://hexdocs.pm/guardian).

