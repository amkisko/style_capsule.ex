defmodule StyleCapsule.CssProcessorPropertyTest do
  use ExUnit.Case, async: true
  use ExUnitProperties

  alias StyleCapsule.CssProcessor

  property "all selectors in scoped CSS are prefixed with capsule ID" do
    check all(
            selectors <- list_of(selector(), min_length: 1, max_length: 5),
            capsule_id <- valid_capsule_id(),
            css_body <- css_body()
          ) do
      css = Enum.join(selectors, ", ") <> " { #{css_body} }"
      scoped = CssProcessor.scope(css, capsule_id)

      # Every selector should be prefixed
      assert scoped =~ ~r/\[data-capsule="#{capsule_id}"\]/

      # Should not raise
      assert is_binary(scoped)
      assert String.length(scoped) > 0
    end
  end

  property "scope never raises for valid inputs" do
    check all(
            css <- css_string(),
            capsule_id <- valid_capsule_id()
          ) do
      result = CssProcessor.scope(css, capsule_id)

      assert is_binary(result)
      assert String.valid?(result)
    end
  end

  property "scope enforces size limits" do
    check all(
            large_css <- binary(length: 1_000_001..2_000_000),
            capsule_id <- valid_capsule_id()
          ) do
      assert_raise ArgumentError, ~r/exceeds maximum size/, fn ->
        CssProcessor.scope(large_css, capsule_id)
      end
    end
  end

  property "nesting strategy wraps entire CSS" do
    check all(
            css <- css_string(),
            capsule_id <- valid_capsule_id()
          ) do
      scoped = CssProcessor.scope(css, capsule_id, strategy: :nesting)

      assert scoped =~ ~r/\[data-capsule="#{capsule_id}"\]\s*\{/
      assert scoped =~ css
    end
  end

  # Generators

  defp selector do
    gen all(
          prefix <- one_of([constant("."), constant("#"), constant("")]),
          name <- string(:alphanumeric, min_length: 1, max_length: 10)
        ) do
      prefix <> name
    end
  end

  defp css_body do
    string(:printable, min_length: 1, max_length: 50)
  end

  defp css_string do
    gen all(rules <- list_of(css_rule(), min_length: 1, max_length: 10)) do
      Enum.join(rules, "\n")
    end
  end

  defp css_rule do
    gen all(
          selector <- selector(),
          body <- css_body()
        ) do
      "#{selector} { #{body} }"
    end
  end

  defp valid_capsule_id do
    string(:alphanumeric, min_length: 8, max_length: 32)
    |> map(&String.replace(&1, ~r/[^a-zA-Z0-9_-]/, "a"))
  end
end
