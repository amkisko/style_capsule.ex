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
    validate_css!(css)

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

    StyleCapsule.Instrumentation.css_processor_scope(duration_ms, input_bytes, output_bytes, strategy)

    result
  end

  @doc false
  defp patch_selectors(css, capsule_id) do
    if css == "" or not String.contains?(css, "{") do
      css
    else
      selector_prefix = ~s([data-capsule="#{capsule_id}"])

      css
      |> String.split("\n")
      |> Enum.map_join("\n", &patch_line(&1, selector_prefix))
    end
  end

  defp patch_line(line, selector_prefix) do
    cond do
      String.contains?(line, "{") and String.contains?(line, "}") ->
        case Regex.run(~r/^(\s*)([^{]+)(\{[^}]+\})/, line) do
          [_, indent, selectors, rules] ->
            indent <> scope_selector_list(selectors, selector_prefix) <> " " <> rules

          _ ->
            line
        end

      String.contains?(line, "{") ->
        case Regex.run(~r/^(\s*)([^{]+)\{(.*)$/, line) do
          [_, indent, selectors, rest] ->
            indent <> scope_selector_list(selectors, selector_prefix) <> " {" <> rest

          _ ->
            line
        end

      true ->
        line
    end
  end

  defp scope_selector_list(selectors, selector_prefix) do
    selectors
    |> String.trim()
    |> String.split(",")
    |> Enum.map(&String.trim/1)
    |> Enum.map_join(", ", &scope_one_selector(&1, selector_prefix))
  end

  defp scope_one_selector("", _selector_prefix), do: ""

  defp scope_one_selector(selector, selector_prefix) do
    cond do
      String.starts_with?(selector, "@") ->
        selector

      keyframe_stop?(selector) ->
        selector

      true ->
        translated = translate_host_selector(selector, selector_prefix)

        if String.contains?(translated, selector_prefix) do
          translated
        else
          selector_prefix <> " " <> translated
        end
    end
  end

  defp keyframe_stop?(selector) do
    selector in ["from", "to"] or Regex.match?(~r/\A\d+(\.\d+)?%\z/, selector)
  end

  @doc false
  defp wrap_nesting(css, capsule_id) do
    capsule_attr = ~s([data-capsule="#{capsule_id}"])
    "#{capsule_attr} {\n#{css}\n}"
  end

  @doc false
  defp translate_host_selector(selector, selector_prefix) do
    selector
    |> String.replace(~r/:host-context\(([^)]*)\)/, selector_prefix <> " \\1")
    |> String.replace(~r/:host\(([^)]*)\)/, selector_prefix <> "\\1")
    |> String.replace(~r/:host\b/, selector_prefix)
  end

  @doc false
  defp validate_capsule_id!(id) do
    StyleCapsule.Id.validate!(id)
  end

  @doc false
  defp validate_css!(css) when is_binary(css) do
    max_size = StyleCapsule.Config.max_css_size()

    if byte_size(css) > max_size do
      raise ArgumentError,
            "CSS content exceeds maximum size of #{max_size} bytes (got #{byte_size(css)} bytes)"
    end

    if String.contains?(String.downcase(css), "</style>") do
      raise ArgumentError, "CSS content must not contain </style>"
    end

    :ok
  end

  defp validate_css!(other) do
    raise ArgumentError, "CSS content must be a binary, got: #{inspect(other)}"
  end
end
