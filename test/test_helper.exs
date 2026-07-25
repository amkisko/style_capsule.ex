if System.get_env("CI") in ["true", "1"] do
  report_dir = "coverage"
  File.mkdir_p!(report_dir)

  Application.put_env(:junit_formatter, :report_dir, Path.expand(report_dir))
  Application.put_env(:junit_formatter, :report_file, "junit-coverage.xml")
  Application.put_env(:junit_formatter, :automatic_create_dir?, true)

  ExUnit.configure(formatters: [JUnitFormatter, ExUnit.CLIFormatter])
end

ExUnit.start()

debug_mode = System.get_env("DEBUG") == "1"

if debug_mode do
  Logger.configure(level: :debug)
else
  Logger.remove_backend(:console)
  Logger.configure(level: :error)
  Application.put_env(:logger, :backends, [])
end
