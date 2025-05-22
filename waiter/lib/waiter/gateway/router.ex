defmodule Waiter.Gateway.Router do
  @moduledoc """
  Documentation for `Waiter.Router`.
  """
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  match _ do
    Waiter.Gateway.Handler.route(conn)
  end
end
