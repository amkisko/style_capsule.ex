defmodule PhoenixDemo.MixProject do
  use Mix.Project

  def project do
    [
      app: :phoenix_demo,
      version: "0.1.0",
      elixir: "~> 1.18",
      elixir_paths: elixir_paths(Mix.env()),
      compilers: Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      listeners: [Phoenix.CodeReloader],
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {PhoenixDemo.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixir_paths(:test), do: ["lib", "test/support"]
  defp elixir_paths(_), do: ["lib"]

  defp deps do
    [
      {:phoenix, "~> 1.8"},
      {:phoenix_live_view, "~> 1.1"},
      {:phoenix_html, "~> 4.3"},
      {:phoenix_live_reload, "~> 1.4", only: :dev},
      {:gettext, "~> 0.24"},
      {:jason, "~> 1.4"},
      {:plug_cowboy, "~> 2.7"},
      {:style_capsule, path: "../.."}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      "assets.deploy": [
        "style_capsule.build",
        "phx.digest"
      ]
    ]
  end
end
