defmodule WaiterController.Ingress.Parser do
  @moduledoc false

  def parse_ingress(ingress) do
    spec = get_in(ingress, ["spec"])
    rules = Map.get(spec, "rules", [])

    Enum.reduce(rules, %{}, fn rule, acc ->
      host = rule["host"]
      paths = get_in(rule, ["http", "paths"]) || []

      Enum.reduce(paths, acc, fn path, acc2 ->
        path_str = path["path"] || "/"
        backend = path["backend"]
        svc_name = get_in(backend, ["service", "name"])
        svc_port = get_in(backend, ["service", "port", "number"]) || 80

        backend_url = "http://#{svc_name}:#{svc_port}"
        Map.put(acc2, {host, path_str}, backend_url)
      end)
    end)
  end
end
