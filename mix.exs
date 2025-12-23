defmodule StyleCapsule.MixProject do
  use Mix.Project

  @version "0.5.0"
  @source_url "https://github.com/amkisko/style_capsule.ex"

  def project do
    [
      app: :style_capsule,
      version: @version,
      elixir: "~> 1.18",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      description: description(),
      docs: docs(),
      aliases: aliases(),
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.json": :test,
        "coveralls.html": :test,
        "test.all": :test,
        credo: :test,
        dialyzer: :test
      ],
      dialyzer: [
        # Include Mix so Dialyzer knows about Mix.Task and Mix.shell
        plt_add_apps: [:mix],
        ignore_warnings: "dialyzer.ignore-warnings"
      ],
      test_coverage: [
        tool: ExCoveralls
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger, :crypto]
    ]
  end

  defp deps do
    [
      # Phoenix dependencies (optional, for Phoenix integration)
      {:phoenix, "~> 1.7", optional: true},
      {:phoenix_live_view, "~> 0.20", optional: true},
      {:phoenix_html, "~> 4.0", optional: true},
      {:plug, "~> 1.14", optional: true},
      {:plug_cowboy, "~> 2.6", optional: true},

      # Testing
      {:stream_data, "~> 1.0", only: :test},

      # Code quality
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:excoveralls, "~> 0.18", only: :test, runtime: false},
      {:benchee, "~> 1.0", only: :dev, runtime: false},
      {:benchee_html, "~> 1.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    [
      maintainers: ["Andrei Makarov"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => "#{@source_url}/blob/main/CHANGELOG.md"
      },
      files: ~w(
        lib mix.exs README.md CHANGELOG.md LICENSE.md .formatter.exs
        benchmarks/README.md MIGRATION_FROM_RUBY.md
      )
    ]
  end

  defp description do
    """
    Attribute-based CSS scoping for Phoenix LiveView components and standalone Elixir applications.
    Provides component-scoped CSS encapsulation using [data-capsule] attributes.
    """
  end

  defp docs do
    [
      main: "readme",
      source_url: @source_url,
      extras: [
        "README.md",
        "CHANGELOG.md",
        "MIGRATION_FROM_RUBY.md",
        "CONTRIBUTING.md",
        "LICENSE.md"
      ]
    ]
  end

  defp aliases do
    [
      "test.all": ["test", "credo", "dialyzer"],
      quality: ["format --check-formatted", "credo --strict", "dialyzer", "test"],
      "quality.fix": ["format", "credo --strict"],
      ci: ["test", "credo", "dialyzer"],
      bench: ["style_capsule.bench"]
    ]
  end
end
