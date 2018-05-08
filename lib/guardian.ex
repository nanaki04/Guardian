defmodule Guardian do

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do

      import Guardian
      import Supervisor.Spec

      @after_compile Guardian

      Module.register_attribute __MODULE__, :secret, []
      @secret Keyword.get(opts, :secret)

      def start_link() do
        children = [worker(@secret, [], restart: :transient)]
        options = [strategy: :simple_one_for_one, name: __MODULE__]
        Supervisor.start_link children, options
      end

      def start_child(id) do
        unless Guardian.active?(__MODULE__), do: Guardian.Application.start_child(supervisor(__MODULE__, []))
        apply(Module.concat(@secret, Cellar.Guardian), :watch, [id])
        |> start_child(id)
      end
      def start_child(:ok, id), do: Supervisor.start_child(__MODULE__, [id])
      def start_child(error, id), do: error

      def stop() do
        Guardian.Application.terminate_child(__MODULE__)
      end

      def guard(id), do: guard id, apply(@secret, :active?, [id])
      def guard(id, false), do: verify id, start_child(id)
      def guard(id, true), do: :ok

      defp verify(_, {:ok, _}), do: :ok
      defp verify(_, {:ok, _, _}), do: :ok
      defp verify(id, error), do: error

    end
  end

  def active?(module) do
    case GenServer.whereis(module) do
      nil -> false
      _ -> true
    end
  end

  def __after_compile__(env, _) do
    import Supervisor.Spec

    unless active?(env.module), do: Guardian.Application.start_child(supervisor(env.module, []))
  end
end
