# Ensure the project is compiled
Mix.Task.run("compile")

# Start telemetry to avoid warnings
Application.ensure_all_started(:telemetry)

alias StyleCapsule.CssProcessor

# Generate test CSS of various sizes
small_css = """
.card { color: red; }
.title { font-size: 24px; }
.content { padding: 16px; }
"""

medium_css = """
.card { color: red; background: white; border: 1px solid #ccc; }
.title { font-size: 24px; font-weight: bold; margin-bottom: 8px; }
.content { padding: 16px; line-height: 1.5; }
.button { padding: 8px 16px; border-radius: 4px; cursor: pointer; }
.button:hover { background: #f0f0f0; }
.button:active { transform: scale(0.98); }
"""

large_css = """
.card { color: red; background: white; border: 1px solid #ccc; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
.title { font-size: 24px; font-weight: bold; margin-bottom: 8px; color: #333; }
.content { padding: 16px; line-height: 1.5; color: #666; }
.button { padding: 8px 16px; border-radius: 4px; cursor: pointer; background: #007bff; color: white; }
.button:hover { background: #0056b3; transform: translateY(-1px); }
.button:active { transform: scale(0.98); }
.input { padding: 8px; border: 1px solid #ddd; border-radius: 4px; width: 100%; }
.input:focus { outline: none; border-color: #007bff; box-shadow: 0 0 0 3px rgba(0,123,255,0.1); }
@media (max-width: 768px) { .card { padding: 12px; } .title { font-size: 20px; } }
@keyframes fadeIn { from { opacity: 0; } to { opacity: 1; } }
.animated { animation: fadeIn 0.3s ease-in; }
"""

very_large_css = String.duplicate(medium_css, 10)

capsule_id = "test_capsule_12345"

Benchee.run(
  %{
    "scope_patch_small" => fn -> CssProcessor.scope(small_css, capsule_id, strategy: :patch) end,
    "scope_patch_medium" => fn -> CssProcessor.scope(medium_css, capsule_id, strategy: :patch) end,
    "scope_patch_large" => fn -> CssProcessor.scope(large_css, capsule_id, strategy: :patch) end,
    "scope_patch_very_large" => fn -> CssProcessor.scope(very_large_css, capsule_id, strategy: :patch) end,
    "scope_nesting_small" => fn -> CssProcessor.scope(small_css, capsule_id, strategy: :nesting) end,
    "scope_nesting_medium" => fn -> CssProcessor.scope(medium_css, capsule_id, strategy: :nesting) end,
    "scope_nesting_large" => fn -> CssProcessor.scope(large_css, capsule_id, strategy: :nesting) end,
    "scope_nesting_very_large" => fn -> CssProcessor.scope(very_large_css, capsule_id, strategy: :nesting) end
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
    {Benchee.Formatters.HTML, file: "benchmarks/output/css_processor.html"}
  ]
)
