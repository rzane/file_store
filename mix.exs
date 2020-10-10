defmodule FileStore.MixProject do
  use Mix.Project

  def project do
    [
      app: :file_store,
      version: "0.0.0",
      elixir: "~> 1.8",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package(),
      test_coverage: [tool: ExCoveralls],
      dialyzer: [
        plt_add_apps: [:ecto, :ex_aws, :ex_aws_s3],
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
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
      links: %{"GitHub" => "https://github.com/rzane/file_store"}
    ]
  end

  defp deps do
    [
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:hackney, ">= 0.0.0", only: :test},
      {:sweet_xml, ">= 0.0.0", only: :test},
      {:jason, ">= 0.0.0", only: :test},
      {:excoveralls, "~> 0.13", only: :test},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false}
    ]
  end
end
