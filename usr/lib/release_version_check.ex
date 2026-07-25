defmodule ReleaseVersionCheck do
  @moduledoc false

  @yellow "\e[1;33m"
  @reset "\e[0m"

  def warn_if_already_released(version, package_name, registry \\ :hex) do
    warnings = []

    existing_tags = existing_git_tags(version)

    warnings =
      if existing_tags == [] do
        warnings
      else
        warnings ++ ["git tag exists (#{Enum.join(existing_tags, ", ")})"]
      end

    warnings =
      if registry_version_exists?(version, package_name, registry) do
        warnings ++ ["#{registry_label(registry)} has version #{version}"]
      else
        warnings
      end

    if warnings != [] do
      IO.puts(
        "\n#{@yellow}Warning: version #{version} may already be released (#{Enum.join(warnings, "; ")}).#{@reset}"
      )
    end
  end

  def existing_git_tags(version) do
    Enum.filter([version, "v#{version}"], fn tag ->
      {_output, exit_code} =
        System.cmd("git", ["rev-parse", "--verify", "refs/tags/#{tag}"], stderr_to_stdout: true)

      exit_code == 0
    end)
  end

  def registry_version_exists?(version, package_name, registry) do
    case registry do
      :rubygems -> rubygems_version_exists?(version, package_name)
      :hex -> hex_version_exists?(version, package_name)
      :crates_io -> crates_io_version_exists?(version, package_name)
      _ -> false
    end
  end

  def registry_label(registry) do
    case registry do
      :rubygems -> "RubyGems"
      :hex -> "Hex"
      :crates_io -> "crates.io"
      other -> to_string(other)
    end
  end

  defp rubygems_version_exists?(version, gem_name) do
    case http_get("https://rubygems.org/api/v1/versions/#{gem_name}.json") do
      {:ok, body} ->
        body
        |> :json.decode()
        |> Enum.any?(fn entry -> entry["number"] == version end)

      _ ->
        false
    end
  rescue
    _ -> false
  end

  defp hex_version_exists?(version, package_name) do
    case http_get("https://hex.pm/api/packages/#{package_name}/releases/#{version}") do
      {:ok, _body} -> true
      _ -> false
    end
  end

  defp crates_io_version_exists?(version, crate_name) do
    case http_get("https://crates.io/api/v1/crates/#{crate_name}/#{version}") do
      {:ok, _body} -> true
      _ -> false
    end
  end

  defp http_get(url) do
    :inets.start()
    :ssl.start()

    headers = [{~c"user-agent", ~c"release-version-check"}]

    case :httpc.request(:get, {String.to_charlist(url), headers}, [{:timeout, 5_000}], []) do
      {:ok, {{_, 200, _}, _response_headers, body}} ->
        {:ok, IO.iodata_to_binary(body)}

      _ ->
        :error
    end
  rescue
    _ -> :error
  end
end
