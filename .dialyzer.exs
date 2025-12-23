[
  plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
  plt_add_apps: [:mix, :ex_unit],
  flags: [
    :error_handling,
    :race_conditions,
    :underspecs,
    :unknown
  ]
]

