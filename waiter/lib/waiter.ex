defmodule Waiter do
  @moduledoc """
  Documentation for `Waiter`.
  """

  defmodule GatewaySupervisor do
    @moduledoc """
    Supervisor for the Waiter application.
    """
    use Supervisor

    def start_link(args) do
      Supervisor.start_link(__MODULE__, args, name: __MODULE__)
    end

    @impl true
    def init(_args) do
      children = [
        {Bandit, plug: Waiter.Gateway.Router, scheme: :http, port: 9080},
        {Finch, name: WaiterFinch},
        Waiter.Gateway.RouteTable
      ]

      Supervisor.init(children, strategy: :one_for_one)
    end
  end
end
