defmodule Waiter.Gateway.RouteTable do
  @moduledoc """
  Documentation for `Waiter.RouteTable`.
  """
  use GenServer

  @table :waiter_routes

  @doc """
  Returns the current routes in the ETS table.
  """
  @impl true
  def init(_state) do
    :ets.new(@table, [:named_table, :public, :set, read_concurrency: true])
    :pg.join(:waiter_workers, self())

    # TODO remove this later
    default_routes = %{
      {"example.com", "/"} => "http://example.com:80"
    }

    load_routes(default_routes)

    {:ok, %{}}
  end

  @impl true
  def handle_info({:route_update, update}, state) do
    apply_update(update)
    {:noreply, state}
  end

  defp apply_update(%{"event" => "DELETED", "routes" => routes}) do
    Enum.each(routes, fn key -> :ets.delete(@table, key) end)
  end

  defp apply_update(%{"routes" => routes}) do
    Enum.each(routes, fn {key, backend} -> :ets.insert(@table, {key, backend}) end)
  end

  defp load_routes(routes) when is_map(routes) do
    :ets.delete_all_objects(@table)

    Enum.each(routes, fn {{host, path}, backend_url} ->
      :ets.insert(@table, {{host, path}, backend_url})
    end)
  end

  @doc """
  Starts GenServer and the ETS table.
  """
  def start_link(_opts) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @doc """
  Performs a lookup on the ETS table.

  Returns {:ok, backend_url} or :error.
  """
  def lookup(host, path) do
    case :ets.lookup(@table, {host, path}) do
      [{{^host, ^path}, backend_url}] -> {:ok, backend_url}
      _ -> :error
    end
  end
end
