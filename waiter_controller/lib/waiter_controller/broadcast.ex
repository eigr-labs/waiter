defmodule WaiterController.Broadcast do
  @moduledoc false

  def broadcast_update(update) do
    :pg.get_members(:waiter_workers)
    |> Enum.each(fn pid ->
      send(pid, {:route_update, update})
    end)
  end
end
