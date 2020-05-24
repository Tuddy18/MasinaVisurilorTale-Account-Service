defmodule Accounts.MixProject do
  use Mix.Project

  def project do
    [
      app: :accounts,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Accounts.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:poison, "~> 3.0", override: true},
      {:plug, "~> 1.6"},
      {:cowboy, "~> 2.4"},
      {:plug_cowboy, "~> 2.0"},
      {:timex, "~> 3.0"},
      {:jsonapi, "~> 0.3.0"},
      {:joken, "~> 1.5.0"},
      {:cors_plug, "~> 1.5"},
#      {:myxql, "~> 0.3.0"},
    {:ecto, "~> 2.0"},
    {:mariaex, "~> 0.7"},
    {:safetybox, "~> 0.1.2" }
    ]
  end
end
