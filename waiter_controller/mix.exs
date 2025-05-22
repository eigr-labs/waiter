defmodule WaiterController.MixProject do
  use Mix.Project

  def project do
    [
      app: :waiter_controller,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {WaiterController.Application, []}
    ]
  end

  defp deps do
    [
      {:castore, "~> 1.0"},
      {:k8s, "~> 2.6"},
      {:libcluster, "~> 3.5"}
    ]
  end
end
