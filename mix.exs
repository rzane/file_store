defmodule FileStore.MixProject do
  use Mix.Project

  def project do
    [
      app: :file_store,
      version: "0.1.0",
      elixir: "~> 1.8",
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
      {:ex_aws_s3, "~> 2.0", optional: true},
      {:hackney, ">= 0.0.0", optional: true},
      {:sweet_xml, ">= 0.0.0", optional: true},
      {:credo, "~> 1.1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
