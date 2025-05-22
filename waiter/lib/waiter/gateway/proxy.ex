defmodule Waiter.Gateway.Proxy do
  @moduledoc """
  Documentation for `Waiter.Gateway.Proxy`.
  """
  import(Plug.Conn)

  def forward(conn, backend_url) do
    url = backend_url <> conn.request_path

    method =
      conn.method
      |> String.downcase()
      |> String.to_existing_atom()
      |> IO.inspect(label: "HTTP method")

    headers = Enum.into(conn.req_headers, [])

    {:ok, body, _conn} = read_body(conn)

    req = Finch.build(method, url, headers, body)

    case Finch.request(req, WaiterFinch) do
      {:ok, %Finch.Response{status: status, headers: resp_headers, body: resp_body}} ->
        conn
        |> put_resp_headers(resp_headers)
        |> send_resp(status, resp_body)

      {:error, reason} ->
        send_resp(conn, 502, "Bad Gateway: #{inspect(reason)}")
    end
  end

  defp put_resp_headers(conn, headers) do
    Enum.reduce(headers, conn, fn {k, v}, acc -> put_resp_header(acc, k, v) end)
  end
end
