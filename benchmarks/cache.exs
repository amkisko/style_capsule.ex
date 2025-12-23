# Ensure the project is compiled
Mix.Task.run("compile")

# Start telemetry to avoid warnings
Application.ensure_all_started(:telemetry)

alias StyleCapsule.Cache

capsule_id = "test_capsule_12345"
css_source = ".card { color: red; background: white; }"
compute_fn = fn -> "[data-capsule=\"#{capsule_id}\"] .card { color: red; background: white; }" end

# Warm up cache
Cache.get_or_compute(capsule_id, css_source, compute_fn, strategy: :time, ttl: 1000)

Benchee.run(
  %{
    "cache_none" => fn ->
      Cache.get_or_compute(capsule_id, css_source, compute_fn, strategy: :none)
    end,
    "cache_time_hit" => fn ->
      Cache.get_or_compute(capsule_id, css_source, compute_fn, strategy: :time, ttl: 1000)
    end,
    "cache_time_miss" => fn ->
      unique_id = "unique_#{System.unique_integer([:positive])}"
      Cache.get_or_compute(unique_id, css_source, compute_fn, strategy: :time, ttl: 1000)
    end,
    "cache_custom_function" => fn ->
      custom_fn = fn _css, _id, _ns ->
        {"custom_key", true, System.system_time(:millisecond) + 1000}
      end

      Cache.get_or_compute(capsule_id, css_source, compute_fn, strategy: custom_fn)
    end,
    "cache_clear_all" => fn ->
      Cache.clear()
    end,
    "cache_clear_key" => fn ->
      Cache.clear("style_capsule:test")
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
    {Benchee.Formatters.HTML, file: "benchmarks/output/cache.html"}
  ]
)
