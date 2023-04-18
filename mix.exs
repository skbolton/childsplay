defmodule Childsplay.MixProject do
  use Mix.Project

  @source_url "https://github.com/skbolton/childsplay"
  @version "0.1.0"

  def project do
    [
      app: :childsplay,
      version: @version,
      elixir: "~> 1.14",

      # Hex
      description: "Helpers for building a Supervisor's children",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  defp package do
    [
      maintainers: ["Stephen Bolton"],
      licenses: ["MIT"],
      links: %{"GitHub" => @source_url},
      files: ~w(.formatter.exs mix.exs README.md lib)
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
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end
end
