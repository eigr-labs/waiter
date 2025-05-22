defmodule Waiter.Application do
  @moduledoc false
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      {Waiter.GatewaySupervisor, []}
    ]

    opts = [strategy: :one_for_one, name: Waiter.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
