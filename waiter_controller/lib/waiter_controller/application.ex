defmodule WaiterController.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      WaiterController.Ingress.Watcher
    ]

    opts = [strategy: :one_for_one, name: WaiterController.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
