defmodule StyleCapsule.StylesheetRegistryTest do
  use ExUnit.Case, async: false
  doctest StyleCapsule.StylesheetRegistry

  alias StyleCapsule.{Registry, StylesheetRegistry}

  setup do
    StylesheetRegistry.clear()
    :ok
  end

  describe "register_inline/3" do
    test "registers inline CSS" do
      assert StylesheetRegistry.register_inline(".test { color: red; }", "abc12345") == :ok
      styles = StylesheetRegistry.get_inline_styles()
      assert length(styles) == 1
      assert hd(styles).id == "abc12345"
      assert hd(styles).css == ".test { color: red; }"
    end

    test "deduplicates by capsule ID" do
      StylesheetRegistry.register_inline(".test1 { color: red; }", "abc12345")
      StylesheetRegistry.register_inline(".test2 { color: blue; }", "abc12345")
      styles = StylesheetRegistry.get_inline_styles()
      assert length(styles) == 1
    end

    test "supports namespaces" do
      StylesheetRegistry.register_inline(".test { color: red; }", "abc12345", namespace: :admin)
      StylesheetRegistry.register_inline(".test { color: blue; }", "def67890", namespace: :user)

      admin_styles = StylesheetRegistry.get_inline_styles(:admin)
      user_styles = StylesheetRegistry.get_inline_styles(:user)

      assert length(admin_styles) == 1
      assert length(user_styles) == 1
      assert hd(admin_styles).id == "abc12345"
      assert hd(user_styles).id == "def67890"
    end
  end

  describe "register_stylesheet/2" do
    test "registers stylesheet link" do
      assert StylesheetRegistry.register_stylesheet("/assets/card.css") == :ok
      links = StylesheetRegistry.get_stylesheet_links()
      assert length(links) == 1
      assert hd(links).href == "/assets/card.css"
    end

    test "deduplicates by href" do
      StylesheetRegistry.register_stylesheet("/assets/card.css")
      StylesheetRegistry.register_stylesheet("/assets/card.css")
      links = StylesheetRegistry.get_stylesheet_links()
      assert length(links) == 1
    end
  end

  describe "clear/1" do
    test "clears all namespaces" do
      StylesheetRegistry.register_inline(".test { color: red; }", "abc12345", namespace: :admin)
      StylesheetRegistry.register_inline(".test { color: blue; }", "def67890", namespace: :user)
      StylesheetRegistry.clear()

      assert StylesheetRegistry.get_inline_styles(:admin) == []
      assert StylesheetRegistry.get_inline_styles(:user) == []
    end

    test "clears specific namespace" do
      StylesheetRegistry.register_inline(".test { color: red; }", "abc12345", namespace: :admin)
      StylesheetRegistry.register_inline(".test { color: blue; }", "def67890", namespace: :user)
      StylesheetRegistry.clear(:admin)

      assert StylesheetRegistry.get_inline_styles(:admin) == []
      assert length(StylesheetRegistry.get_inline_styles(:user)) == 1
    end
  end

  describe "legacy StyleCapsule.Registry" do
    test "delegates to StylesheetRegistry" do
      assert Registry.register_inline(".legacy { color: red; }", "legacy123") == :ok
      assert StylesheetRegistry.get_inline_styles() |> length() == 1
    end

    test "reads data stored under the legacy process key" do
      Process.put(:style_capsule_registry, %{
        inline: %{default: [%{id: "legacy", css: ".legacy {}", attrs: [], capsule_id: "legacy"}]},
        links: %{}
      })

      assert length(StylesheetRegistry.get_inline_styles()) == 1
    end
  end
end
