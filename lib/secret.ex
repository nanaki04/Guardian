defmodule Guardian.Secret do
  @moduledoc """
  Guardian is an application designed to add supervision with state recovery
  to GenServers with a simple use declaration.

  ## Examples

      iex> defmodule Server do
      ...>   use Guardian.Secret
      ...>
      ...>   def make_initial_state(id), do: %{id: id, val: 5}
      ...>
      ...>   def add(id, num) do
      ...>     :ok = guard(id)
      ...>     call id, {:add, num}
      ...>   end
      ...>
      ...>   def handle_call({:add, num}, _, %{val: x} = state) do
      ...>     x + num |> (&{:reply, &1, %{state | val: &1}}).()
      ...>   end
      ...> end
      ...>
      ...> Server.add "1", 3
      8
      ...> Server.stop_gracefully "1"
      ...> Server.active? "1"
      false
      ...> Server.add "1", 2
      10
      ...> Server.stop_gracefully("1", true)
      ...> Server.active? "1"
      false
      ...> Server.add "1", 2
      7

  """

  @callback make_initial_state(String.t) :: map
  @callback id_to_name(String.t) :: GenServer.name

  defmacro __using__(_opts) do
    quote do
      import Guardian.Secret

      defmodule Cellar do
        use Guardian.Cellar
      end

      @spec make_initial_state(String.t) :: map
      def make_initial_state(id) do
        %{id: id}
      end

      @spec id_to_name(String.t) :: GenServer.name
      def id_to_name(id) do
        {:global, Atom.to_string(__MODULE__) <> id}
      end

      @spec active?(String.t) :: boolean
      def active?(id) do
        case GenServer.whereis(id_to_name(id)) do
          nil -> false
          _ -> true
        end
      end

      @spec guard(String.t) :: :ok | {:error, any}
      def guard(id) do
        apply Module.concat(__MODULE__, Guardian), :guard, [id]
      end

      @spec start_link(String.t) :: GenServer.on_start
      def start_link(id) do
        apply(Cellar, :retrieve, [id])
        |> (&(GenServer.start_link __MODULE__, &1, name: id_to_name(id))).()
      end

      @spec call(String.t, term, timeout) :: term
      def call(id, args, timeout \\ 5000), do: GenServer.call id_to_name(id), args, timeout

      @spec stop_gracefully(String.t, boolean) :: :ok
      def stop_gracefully(id, delete_state \\ false) do
        GenServer.stop id_to_name(id), :normal
        if delete_state do
          Cellar.stop(id)
          apply(Module.concat(__MODULE__, Guardian), :stop, [])
        end
      end

      def init(state) do
        {:ok, state}
      end

      def terminate(_reason, %{id: id} = state) do
        apply(Cellar, :store, [id, state])
      end

      defoverridable [make_initial_state: 1, id_to_name: 1]

      @before_compile Guardian.Secret
    end
  end

  defmacro __before_compile__(env) do
    quote do

      defmodule unquote(Module.concat(env.module, Guardian)) do
        use Guardian, secret: unquote(env.module)
      end

      defmodule Cellar.Guardian do
        use Guardian.Cellar.Guardian, secret: unquote(env.module)
      end

    end
  end

end
