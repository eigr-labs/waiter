defmodule WaiterController.Ingress.Watcher do
  @moduledoc false
  use GenServer
  require Logger

  alias K8s.Client
  alias K8s.Conn

  alias WaiterController.Broadcast
  alias WaiterController.Ingress.Parser

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(_state) do
    {:ok, conn} = Conn.from_file("~/.kube/config")
    watch_ingresses(conn)
    {:ok, %{conn: conn}}
  end

  defp watch_ingresses(conn) do
    op = Client.watch("networking.k8s.io/v1", "Ingress", namespace: :all)

    spawn(fn -> stream_events(conn, op) end)
  end

  defp stream_events(conn, op) do
    {:ok, stream} = Client.run(conn, op)

    Enum.each(stream, fn
      {:ok, %{"type" => type, "object" => ingress}} ->
        process_event(type, ingress)

      {:error, reason} ->
        Logger.error("Watch error: #{inspect(reason)}")
    end)
  end

  defp process_event("ADDED", ingress), do: publish_change(:added, ingress)
  defp process_event("MODIFIED", ingress), do: publish_change(:modified, ingress)
  defp process_event("DELETED", ingress), do: publish_change(:deleted, ingress)

  defp publish_change(type, ingress) do
    routes = Parser.parse_ingress(ingress)

    message = %{
      event: type,
      ingress: ingress["metadata"]["name"],
      namespace: ingress["metadata"]["namespace"],
      routes: routes
    }

    Broadcast.broadcast_update(message)
  end
end
