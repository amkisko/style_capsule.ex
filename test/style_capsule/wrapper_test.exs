defmodule StyleCapsule.WrapperTest do
  use ExUnit.Case, async: true
  doctest StyleCapsule.Wrapper

  alias StyleCapsule.Wrapper

  describe "wrap/3" do
    test "wraps HTML with default div tag" do
      html = "<div class=\"content\">Hello</div>"
      result = Wrapper.wrap(html, "abc12345")

      assert result =~ ~r/<div data-capsule="abc12345"/
      assert result =~ html
      assert result =~ "</div>"
    end

    test "respects custom tag option" do
      html = "<span>Hello</span>"
      result = Wrapper.wrap(html, "abc12345", tag: :span)

      assert result =~ ~r/<span data-capsule="abc12345"/
      assert result =~ "</span>"
    end

    test "adds additional attributes" do
      html = "<div>Hello</div>"
      result = Wrapper.wrap(html, "abc12345", attrs: [class: "wrapper", id: "main"])

      assert result =~ ~r/data-capsule="abc12345"/
      assert result =~ ~r/class="wrapper"/
      assert result =~ ~r/id="main"/
    end

    test "escapes attribute values" do
      html = "<div>Hello</div>"
      result = Wrapper.wrap(html, "abc12345", attrs: [title: "Hello \"World\""])

      assert result =~ ~r/title="Hello &quot;World&quot;"/
    end

    test "raises on invalid capsule ID" do
      html = "<div>Hello</div>"

      assert_raise ArgumentError, fn ->
        Wrapper.wrap(html, "invalid id!")
      end
    end
  end
end
