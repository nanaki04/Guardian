defmodule Guardian.Application do
  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Guardian.Worker.start_link(arg1, arg2, arg3)
      # worker(Guardian.Worker, [arg1, arg2, arg3]),
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Guardian.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def start_child(child) do
    :ok = Application.ensure_started(:guardian)
    Supervisor.start_child Guardian.Supervisor, child
  end

  def terminate_child(id) do
    case Supervisor.terminate_child(Guardian.Supervisor, id) do
      {:error, :not_found} ->
        Supervisor.delete_child(Guardian.Supervisor, id)
        :ok
      :ok ->
        Supervisor.delete_child(Guardian.Supervisor, id)
        :ok
      x -> x
    end
  end
end
