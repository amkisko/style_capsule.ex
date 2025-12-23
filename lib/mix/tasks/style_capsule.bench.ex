defmodule Mix.Tasks.StyleCapsule.Bench do
  @moduledoc """
  Runs performance benchmarks for StyleCapsule operations.

  ## Usage

      mix style_capsule.bench                    # Run all benchmarks
      mix style_capsule.bench css_processor       # Run CSS processor benchmarks
      mix style_capsule.bench id_generation      # Run ID generation benchmarks
      mix style_capsule.bench cache               # Run cache benchmarks
      mix style_capsule.bench file_writer         # Run file writer benchmarks

  ## Output

  Benchmarks generate:
  - Console output with statistics
  - HTML reports in `benchmarks/output/` directory
  """

  use Mix.Task

  @shortdoc "Runs StyleCapsule performance benchmarks"

  @impl Mix.Task
  def run(args) do
    Mix.Task.run("compile")

    benchmark_name = List.first(args) || "all"

    benchmarks_dir = Path.join([File.cwd!(), "benchmarks"])
    output_dir = Path.join(benchmarks_dir, "output")

    # Ensure output directory exists
    File.mkdir_p!(output_dir)

    benchmark_file = Path.join(benchmarks_dir, "#{benchmark_name}.exs")

    if File.exists?(benchmark_file) do
      Mix.shell().info("Running benchmark: #{benchmark_name}")
      Mix.shell().info("Output directory: #{output_dir}")

      # Run the benchmark script
      Code.eval_file(benchmark_file)

      Mix.shell().info("Benchmark complete! Check #{output_dir} for HTML reports.")
    else
      Mix.shell().error("Benchmark file not found: #{benchmark_file}")
      Mix.shell().info("Available benchmarks:")
      Mix.shell().info("  - all")
      Mix.shell().info("  - css_processor")
      Mix.shell().info("  - id_generation")
      Mix.shell().info("  - cache")
      Mix.shell().info("  - file_writer")
    end
  end
end
