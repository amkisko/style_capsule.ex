defmodule StyleCapsuleTest do
  use ExUnit.Case, async: true
  doctest StyleCapsule

  alias StyleCapsule

  test "scope_css/3 delegates to CssProcessor" do
    css = ".section { color: red; }"
    result = StyleCapsule.scope_css(css, "abc12345")

    assert result =~ ~r/\[data-capsule="abc12345"\]/
  end

  test "wrap/3 delegates to Wrapper" do
    html = "<div>Hello</div>"
    result = StyleCapsule.wrap(html, "abc12345")

    assert result =~ ~r/data-capsule="abc12345"/
  end

  test "capsule_id/2 delegates to Id" do
    id = StyleCapsule.capsule_id(MyAppWeb.Components.Card)

    assert is_binary(id)
    assert String.length(id) >= 8
  end

  test "validate_capsule_id!/1 delegates to Id" do
    assert StyleCapsule.validate_capsule_id!("abc12345") == :ok

    assert_raise ArgumentError, fn ->
      StyleCapsule.validate_capsule_id!("invalid id!")
    end
  end
end
