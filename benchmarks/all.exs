# Ensure the project is compiled
Mix.Task.run("compile")

# Start telemetry to avoid warnings
Application.ensure_all_started(:telemetry)

alias StyleCapsule.{CssProcessor, Id, Cache, FileWriter}

# Setup
tmp_dir = Path.join(System.tmp_dir!(), "style_capsule_bench_#{System.unique_integer([:positive])}")
File.mkdir_p!(tmp_dir)

css = ".card { color: red; background: white; }"
capsule_id = Id.generate(MyAppWeb.Components.Card)
css_source = css
compute_fn = fn -> CssProcessor.scope(css, capsule_id) end

# Warm up
Cache.get_or_compute(capsule_id, css_source, compute_fn, strategy: :time, ttl: 1000)

Benchee.run(
  %{
    "id_generate" => fn -> Id.generate(MyAppWeb.Components.Card) end,
    "css_scope_patch" => fn -> CssProcessor.scope(css, capsule_id, strategy: :patch) end,
    "css_scope_nesting" => fn -> CssProcessor.scope(css, capsule_id, strategy: :nesting) end,
    "cache_time_hit" => fn ->
      Cache.get_or_compute(capsule_id, css_source, compute_fn, strategy: :time, ttl: 1000)
    end,
    "file_write" => fn ->
      FileWriter.write(capsule_id, css, output_dir: tmp_dir)
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
    {Benchee.Formatters.HTML, file: "benchmarks/output/all.html"}
  ]
)

# Cleanup
File.rm_rf!(tmp_dir)
