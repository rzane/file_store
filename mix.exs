defmodule FileStore.MixProject do
  use Mix.Project

  @source_url "https://github.com/rzane/file_store"
  @version "0.0.0"

  def project do
    [
      app: :file_store,
      version: @version,
      elixir: "~> 1.15",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:ex_aws, :ex_aws_s3],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ],
      docs: docs()
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      description: "A unified interface for file storage backends.",
      maintainers: ["Ray Zane"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => @source_url,
        "Changelog" => @source_url <> "/releases"
      }
    ]
  end

  defp deps do
    [
      {:ex_aws_s3, "~> 2.3", optional: true},
      {:hackney, ">= 0.0.0", only: [:dev, :test]},
      {:sweet_xml, ">= 0.0.0", only: [:dev, :test]},
      {:jason, ">= 0.0.0", only: [:dev, :test]},
      {:excoveralls, "~> 0.14", only: :test},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false},
      {:dialyxir, "~> 1.1", only: [:dev, :test], runtime: false},
      {:castore, "~> 1.0", only: [:test]},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url,
      extras: ["README.md"]
    ]
  end
end
