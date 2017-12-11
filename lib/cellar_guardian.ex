defmodule Guardian.Cellar.Guardian do

  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do

      import Guardian.Cellar.Guardian
      import Supervisor.Spec

      @after_compile Guardian.Cellar.Guardian

      Module.register_attribute __MODULE__, :secret, []
      Module.register_attribute __MODULE__, :cellar, []
      @secret Keyword.get(opts, :secret)
      @cellar Module.concat(@secret, Cellar) 

      def start_link() do
        children = [worker(@cellar, [])]
        options = [strategy: :simple_one_for_one, name: __MODULE__]
        Supervisor.start_link children, options
      end

      def start_child(id), do: Supervisor.start_child(__MODULE__, [id, apply(@secret, :make_initial_state, [id])])

      def watch(id), do: watch(id, apply(@cellar, :active?, [id]))
      def watch(id, false), do: verify id, start_child(id)
      def watch(id, true), do: :ok

      defp verify(_, {:ok, _}), do: :ok
      defp verify(_, {:ok, _, _}), do: :ok
      defp verify(id, e), do: e
      #defp verify(id, _), do: {:error, "failed to start cellar"}
    end
  end

  def __after_compile__(env, _) do
    import Supervisor.Spec

    Guardian.Application.start_child(supervisor(env.module, []))
  end
end
