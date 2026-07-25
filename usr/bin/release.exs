#!/usr/bin/env elixir

Code.require_file(Path.expand("../lib/release_version_check.ex", __DIR__))

defmodule ReleaseScript do
  @moduledoc false

  def run do
    IO.puts("\n🔍 Running quality checks...\n")

    project_dir = Path.expand(__DIR__ <> "/../../")
    File.cd!(project_dir)

    IO.puts("📝 Formatting code...")

    unless run_command("mix format --check-formatted") do
      IO.puts("⚠️  Code is not formatted. Running formatter...")
      run_command("mix format")
    end

    IO.puts("\n🔍 Running Credo (code analysis)...")

    unless run_command("mix credo --strict") do
      IO.puts("❌ Credo found issues. Please fix them before releasing.")
      System.halt(1)
    end

    IO.puts("\n🔍 Running Dialyzer (type checking)...")

    unless run_command("mix dialyzer") do
      IO.puts("⚠️  Dialyzer found issues. Review them before releasing.")
    end

    IO.puts("\n🧪 Running tests...")

    unless run_command("MIX_ENV=test mix coveralls.json") do
      IO.puts("❌ Tests failed. Please fix them before releasing.")
      System.halt(1)
    end

    IO.puts("\n📋 Checking git status...")

    {output, exit_code} = System.cmd("git", ["status", "--porcelain"], stderr_to_stdout: true)

    if exit_code != 0 or String.trim(output) != "" do
      IO.puts("\n❌ Git working directory not clean. Please commit your changes first.")
      IO.puts("Note: mix format may have modified files. Review and commit changes before releasing.")
      System.halt(1)
    end

    case extract_version_from_file("mix.exs") do
      nil ->
        IO.puts("❌ Could not determine version from mix.exs")
        System.halt(1)

      version ->
        package_name = "style_capsule"
        hex_file = "#{package_name}-#{version}.tar"

        ReleaseVersionCheck.warn_if_already_released(version, package_name, :hex)

        IO.puts("\n📦 Building package...")

        unless run_command("mix hex.build") do
          IO.puts("❌ Failed to build package.")
          System.halt(1)
        end

        IO.puts("\n✅ Ready to release #{hex_file} v#{version}")
        IO.write("Continue? [Y/n] ")
        answer = IO.gets("") |> String.trim()

        unless answer == "Y" || answer == "" do
          IO.puts("Exiting")
          System.halt(0)
        end

        IO.puts("\n📤 Publishing to Hex...")

        unless run_command("mix hex.publish") do
          IO.puts("❌ Failed to publish to Hex.")
          System.halt(1)
        end

        IO.puts("\n🏷️  Creating git tag...")
        run_command("git tag v#{version}")
        run_command("git push --tags")

        IO.puts("\n🚀 Creating GitHub release...")
        run_command("gh release create v#{version} --generate-notes", allow_failure: true)

        IO.puts("\n✅ Release complete! v#{version}")
    end
  end

  defp run_command(command, opts \\ []) do
    allow_failure = Keyword.get(opts, :allow_failure, false)

    IO.puts("  → #{command}")

    {output, exit_code} = System.cmd("sh", ["-c", command], stderr_to_stdout: true)

    if exit_code == 0 do
      unless String.trim(output) == "" do
        IO.write(output)
      end

      true
    else
      unless allow_failure do
        IO.write(output)
      end

      false
    end
  end

  defp extract_version_from_file(filename) do
    case File.read(filename) do
      {:ok, content} ->
        case Regex.run(~r/@version\s+"([^"]+)"/, content) do
          [_, version] ->
            version

          _ ->
            case Regex.run(~r/version:\s*"([^"]+)"/, content) do
              [_, version] -> version
              _ -> nil
            end
        end

      _ ->
        nil
    end
  end
end

ReleaseScript.run()
