defmodule Waiter.MixProject do
  use Mix.Project

  def project do
    [
      app: :waiter,
      version: "0.1.0",
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger],
      mod: {Waiter.Application, []}
    ]
  end

  defp deps do
    [
      {:castore, "~> 1.0"},
      {:k8s, "~> 2.6"},
      {:bandit, "~> 1.6"},
      {:libcluster, "~> 3.5"},
      {:plug, "~> 1.17"},
      {:finch, "~> 0.19.0"},
      {:jason, "~> 1.4"},
      {:x509, "~> 0.8"}
    ]
  end
end
