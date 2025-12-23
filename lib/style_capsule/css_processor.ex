defmodule StyleCapsule.CssProcessor do
  @moduledoc """
  Processes CSS by scoping selectors with capsule identifiers.

  Supports two strategies:
  - `:patch` - Adds `[data-capsule="..."]` prefix to each selector (default)
  - `:nesting` - Wraps entire CSS block in `[data-capsule="..."] { ... }`
  """

  @type strategy :: :patch | :nesting

  @doc """
  Scopes CSS using the specified strategy.

  ## Options

    * `:strategy` - Scoping strategy (`:patch` or `:nesting`). Defaults to `:patch`.

  ## Examples

      iex> css = ".section { color: red; }"
      iex> StyleCapsule.CssProcessor.scope(css, "abc12345")
      "[data-capsule=\\"abc12345\\"] .section { color: red; }"

      iex> css = ".section { color: red; }"
      iex> StyleCapsule.CssProcessor.scope(css, "abc12345", strategy: :nesting)
      "[data-capsule=\\"abc12345\\"] {\\n.section { color: red; }\\n}"

  """
  @spec scope(binary(), binary(), keyword()) :: binary()
  def scope(css, capsule_id, opts \\ []) do
    strategy = Keyword.get(opts, :strategy, :patch)
    validate_capsule_id!(capsule_id)
    validate_css_size!(css)

    start_time = System.monotonic_time(:microsecond)
    input_bytes = byte_size(css)

    result =
      case strategy do
        :patch -> patch_selectors(css, capsule_id)
        :nesting -> wrap_nesting(css, capsule_id)
        other -> raise ArgumentError, "Unknown strategy: #{inspect(other)}"
      end

    end_time = System.monotonic_time(:microsecond)
    duration_ms = div(end_time - start_time, 1000)
    output_bytes = byte_size(result)

    # Emit telemetry event
    StyleCapsule.Instrumentation.css_processor_scope(duration_ms, input_bytes, output_bytes, strategy)

    result
  end

  @doc false
  defp patch_selectors(css, capsule_id) do
    # Fast-path: if there's no rule opener, nothing to patch
    if css == "" or not String.contains?(css, "{") do
      css
    else
      # NOTE: This is a simplified implementation that adds a prefix to selectors.
      # A full CSS parser can be integrated later if needed.
      selector_prefix = ~s([data-capsule="#{capsule_id}"])

      css
      |> String.split("\n")
      |> Enum.map_join("\n", fn line ->
        cond do
          # Opening rule line on a single line: ".selector { ... }"
          String.contains?(line, "{") and String.contains?(line, "}") ->
            case Regex.run(~r/^(\s*)([^{]+)(\{[^}]+\})/, line) do
              [_, indent, selectors, rules] ->
                scoped_selectors =
                  selectors
                  |> String.trim()
                  |> String.split(",")
                  |> Enum.map(&String.trim/1)
                  |> Enum.map(fn selector ->
                    # Translate :host to root selector
                    translated = translate_host_selector(selector, selector_prefix)

                    # If :host was translated, use it directly; otherwise prefix
                    if translated == selector_prefix do
                      translated
                    else
                      selector_prefix <> " " <> translated
                    end
                  end)
                  |> Enum.map_join(", ", & &1)

                indent <> scoped_selectors <> " " <> rules

              _ ->
                # If pattern doesn't match, leave line as-is
                line
            end

          # Opening rule line for multi-line block: ".selector {"
          String.contains?(line, "{") ->
            case Regex.run(~r/^(\s*)([^{]+)\{(.*)$/, line) do
              [_, indent, selectors, rest] ->
                scoped_selectors =
                  selectors
                  |> String.trim()
                  |> String.split(",")
                  |> Enum.map(&String.trim/1)
                  |> Enum.map_join(", ", fn selector ->
                    # Translate :host to root selector
                    translated = translate_host_selector(selector, selector_prefix)

                    # If :host was translated, use it directly; otherwise prefix
                    if translated == selector_prefix do
                      translated
                    else
                      selector_prefix <> " " <> translated
                    end
                  end)

                indent <> scoped_selectors <> " {" <> rest

              _ ->
                line
            end

          true ->
            line
        end
      end)
    end
  end

  @doc false
  defp wrap_nesting(css, capsule_id) do
    # Wrap the entire CSS in the capsule attribute selector with newlines for readability
    # This matches the Ruby version's formatting
    capsule_attr = ~s([data-capsule="#{capsule_id}"])
    "#{capsule_attr} {\n#{css}\n}"
  end

  @doc false
  defp translate_host_selector(selector, selector_prefix) do
    selector
    # :host(.foo) => [data-capsule="..."].foo
    |> String.replace(~r/:host\(([^)]*)\)/, selector_prefix <> "\\1")
    # :host-context(.foo) => [data-capsule="..."] .foo
    |> String.replace(~r/:host-context\(([^)]*)\)/, selector_prefix <> " \\1")
    # bare :host => [data-capsule="..."]
    |> String.replace(~r/:host\b/, selector_prefix)
  end

  @doc false
  defp validate_capsule_id!(id) do
    StyleCapsule.Id.validate!(id)
  end

  @doc false
  defp validate_css_size!(css) when is_binary(css) do
    max_size = StyleCapsule.Config.max_css_size()

    if byte_size(css) > max_size do
      raise ArgumentError,
            "CSS content exceeds maximum size of #{max_size} bytes (got #{byte_size(css)} bytes)"
    end
  end

  @doc false
  defp validate_css_size!(_), do: :ok
end
