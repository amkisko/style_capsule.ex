#!/usr/bin/env elixir

Mix.install([])

defmodule QualityCheck do
  @moduledoc """
  Quality check script that runs all linting, formatting, and type checking.
  Can be run independently or as part of the release process.
  """

  def run do
    project_dir = Path.expand(__DIR__ <> "/../../")
    File.cd!(project_dir)

    IO.puts("\n🔍 Running quality checks for style_capsule...\n")

    checks = [
      {"Formatting", "mix format --check-formatted"},
      {"Credo (code analysis)", "mix credo --strict"},
      {"Dialyzer (type checking)", "mix dialyzer"},
      {"Tests", "mix test"}
    ]

    results = Enum.map(checks, fn {name, command} ->
      IO.puts("📋 #{name}...")
      {output, exit_code} = System.cmd("sh", ["-c", command], stderr_to_stdout: true)
      
      if exit_code == 0 do
        IO.puts("  ✅ #{name} passed\n")
        {name, :ok}
      else
        IO.puts("  ❌ #{name} failed\n")
        unless String.trim(output) == "" do
          IO.write(output)
        end
        {name, :error}
      end
    end)

    failed = Enum.filter(results, fn {_, status} -> status == :error end)

    if Enum.empty?(failed) do
      IO.puts("\n✅ All quality checks passed!")
      System.halt(0)
    else
      IO.puts("\n❌ Some quality checks failed:")
      Enum.each(failed, fn {name, _} -> IO.puts("  - #{name}") end)
      System.halt(1)
    end
  end
end

QualityCheck.run()

