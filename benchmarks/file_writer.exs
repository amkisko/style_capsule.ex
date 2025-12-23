# Ensure the project is compiled
Mix.Task.run("compile")

# Start telemetry to avoid warnings
Application.ensure_all_started(:telemetry)

alias StyleCapsule.FileWriter

# Setup temporary directory
tmp_dir = Path.join(System.tmp_dir!(), "style_capsule_bench_#{System.unique_integer([:positive])}")
File.mkdir_p!(tmp_dir)

capsule_id = "test_capsule_12345"
small_css = ".card { color: red; }"
medium_css = String.duplicate(".card { color: red; background: white; border: 1px solid #ccc; }", 10)
large_css = String.duplicate(".card { color: red; background: white; border: 1px solid #ccc; }", 100)

# Cleanup function
on_exit = fn ->
  File.rm_rf!(tmp_dir)
end

Benchee.run(
  %{
    "write_small_css" => fn ->
      FileWriter.write("#{capsule_id}_small", small_css, output_dir: tmp_dir)
    end,
    "write_medium_css" => fn ->
      FileWriter.write("#{capsule_id}_medium", medium_css, output_dir: tmp_dir)
    end,
    "write_large_css" => fn ->
      FileWriter.write("#{capsule_id}_large", large_css, output_dir: tmp_dir)
    end,
    "write_with_custom_filename" => fn ->
      filename_pattern = fn id, _css -> "custom-#{id}.css" end
      FileWriter.write(capsule_id, small_css, output_dir: tmp_dir, filename_pattern: filename_pattern)
    end,
    "write_with_namespace" => fn ->
      FileWriter.write(capsule_id, small_css, output_dir: tmp_dir, namespace: :admin)
    end
  },
  time: 5,
  memory_time: 2,
  print: %{
    benchmarking: true,
    configuration: true,
    fast_warning: true
  },
  formatters: [
    {Benchee.Formatters.Console, extended_statistics: true},
    {Benchee.Formatters.HTML, file: "benchmarks/output/file_writer.html"}
  ],
  after_each: fn _ -> File.rm_rf!(tmp_dir) end,
  after_scenario: fn _ -> File.mkdir_p!(tmp_dir) end
)

# Cleanup
on_exit.()
