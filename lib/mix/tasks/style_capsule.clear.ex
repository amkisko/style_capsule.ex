defmodule Mix.Tasks.StyleCapsule.Clear do
  @moduledoc """
  Clears generated CSS capsule files.
  """

  use Mix.Task

  @shortdoc "Clears generated CSS capsule files"

  @impl Mix.Task
  def run(_args) do
    output_dir = StyleCapsule.Config.output_dir()
    fallback_dir = StyleCapsule.Config.fallback_dir()

    Mix.shell().info("Clearing style capsule files...")

    for dir <- [output_dir, fallback_dir] do
      if File.exists?(dir) do
        case File.rm_rf(dir) do
          {:ok, _} -> Mix.shell().info("Cleared: #{dir}")
          error -> Mix.shell().error("Failed to clear #{dir}: #{inspect(error)}")
        end
      end
    end

    Mix.shell().info("Clear complete!")
  end
end
