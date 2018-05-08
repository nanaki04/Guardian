defmodule Guardian.Cellar do

  defmacro __using__(_opts) do
    quote do
      import Guardian.Cellar

      @type state :: map

      @spec id_to_name(String.t) :: GenServer.name
      def id_to_name(id) do
        {:global, Atom.to_string(__MODULE__) <> id}
      end

      @spec start_link(String.t, state) :: GenServer.on_start
      def start_link(id, state) do
        GenServer.start_link __MODULE__, state, name: id_to_name(id)
      end

      def stop(id) do
        GenServer.stop id_to_name(id), :normal
      end

      @spec store(String.t, state) :: state
      def store(id, state) do
        GenServer.call id_to_name(id), {:store, state}
      end

      @spec retrieve(String.t) :: state
      def retrieve(id) do
        GenServer.call id_to_name(id), :retrieve
      end

      @spec active?(String.t) :: boolean
      def active?(id) do
        case GenServer.whereis(id_to_name(id)) do
          nil -> false
          _ -> true
        end
      end

      def init(state) do
        {:ok, state}
      end

      def handle_call({:store, state}, _, _) do
        {:reply, state, state}
      end

      def handle_call(:retrieve, _, state) do
        {:reply, state, state}
      end
    end
  end

end
