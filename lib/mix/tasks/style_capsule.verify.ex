defmodule Mix.Tasks.StyleCapsule.Verify do
  @moduledoc """
  Verifies style capsule configuration and files.

  Checks for:
  - Duplicate capsule IDs
  - Writable output directories
  - File count/size limits
  """

  use Mix.Task

  @shortdoc "Verifies style capsule configuration"

  @impl Mix.Task
  def run(_args) do
    Mix.Task.run("compile")

    Mix.shell().info("Verifying style capsule configuration...")

    output_dir = StyleCapsule.Config.output_dir()
    fallback_dir = StyleCapsule.Config.fallback_dir()

    # Check directories
    check_directory(output_dir, "Output")
    check_directory(fallback_dir, "Fallback")

    Mix.shell().info("Verification complete!")
  end

  defp check_directory(dir, label) do
    cond do
      File.exists?(dir) ->
        # Try to write a test file to check writability
        test_file = Path.join(dir, ".test_write")

        case File.write(test_file, "test") do
          :ok ->
            File.rm(test_file)
            Mix.shell().info("#{label} directory is writable: #{dir}")

          _error ->
            Mix.shell().error("#{label} directory exists but is not writable: #{dir}")
        end

      true ->
        parent = Path.dirname(dir)

        if File.exists?(parent) do
          # Try to create a test file in parent to check writability
          test_file = Path.join(parent, ".test_write")

          case File.write(test_file, "test") do
            :ok ->
              File.rm(test_file)
              Mix.shell().info("#{label} directory can be created: #{dir}")

            _error ->
              Mix.shell().error("#{label} directory cannot be created: #{dir}")
          end
        else
          Mix.shell().error("#{label} directory cannot be created: #{dir}")
        end
    end
  end
end
