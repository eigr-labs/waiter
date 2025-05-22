defmodule Waiter.Gateway.Handler do
  @moduledoc """
  Documentation for `Waiter.Gateway.Handler`.
  """
  import Plug.Conn

  alias Waiter.Gateway.RouteTable
  alias Waiter.Gateway.Proxy

  def route(conn) do
    host = get_req_header(conn, "host") |> List.first() || ""
    path = conn.request_path

    case RouteTable.lookup(host, path) do
      {:ok, backend_url} ->
        Proxy.forward(conn, backend_url)

      :error ->
        send_resp(conn, 404, "No route found for #{host}#{path}")
    end
  end
end
