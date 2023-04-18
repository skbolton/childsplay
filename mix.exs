defmodule Childsplay.MixProject do
  use Mix.Project

  def project do
    [
      app: :childsplay,
      version: "0.1.0",
      description: "Helpers for building a Supervisor's children",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false}
    ]
  end
end
