# Ensure the project is compiled
Mix.Task.run("compile")

# Start telemetry to avoid warnings
Application.ensure_all_started(:telemetry)

alias StyleCapsule.Id

# Test data
modules = [
  MyAppWeb.Components.Card,
  MyAppWeb.Components.Button,
  MyAppWeb.Components.Modal,
  MyAppWeb.Components.Input,
  MyAppWeb.Components.Dropdown
]

terms = [
  "user_profile",
  "admin_panel",
  "dashboard_widget",
  "navigation_menu",
  "footer_component"
]

Benchee.run(
  %{
    "generate_from_module" => fn ->
      Enum.each(modules, fn mod -> Id.generate(mod) end)
    end,
    "generate_from_term" => fn ->
      Enum.each(terms, fn term -> Id.generate(term) end)
    end,
    "generate_with_prefix" => fn ->
      Enum.each(modules, fn mod -> Id.generate(mod, prefix: "comp") end)
    end,
    "generate_with_custom_length" => fn ->
      Enum.each(modules, fn mod -> Id.generate(mod, length: 16) end)
    end,
    "validate_id" => fn ->
      id = Id.generate(MyAppWeb.Components.Card)
      Enum.each(1..100, fn _ -> Id.validate!(id) end)
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
    {Benchee.Formatters.HTML, file: "benchmarks/output/id_generation.html"}
  ]
)
