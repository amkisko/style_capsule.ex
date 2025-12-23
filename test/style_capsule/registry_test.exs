defmodule StyleCapsule.RegistryTest do
  use ExUnit.Case, async: false
  doctest StyleCapsule.Registry

  alias StyleCapsule.Registry

  setup do
    Registry.clear()
    :ok
  end

  describe "register_inline/3" do
    test "registers inline CSS" do
      assert Registry.register_inline(".test { color: red; }", "abc12345") == :ok
      styles = Registry.get_inline_styles()
      assert length(styles) == 1
      assert hd(styles).id == "abc12345"
      assert hd(styles).css == ".test { color: red; }"
    end

    test "deduplicates by capsule ID" do
      Registry.register_inline(".test1 { color: red; }", "abc12345")
      Registry.register_inline(".test2 { color: blue; }", "abc12345")
      styles = Registry.get_inline_styles()
      assert length(styles) == 1
    end

    test "supports namespaces" do
      Registry.register_inline(".test { color: red; }", "abc12345", namespace: :admin)
      Registry.register_inline(".test { color: blue; }", "def67890", namespace: :user)

      admin_styles = Registry.get_inline_styles(:admin)
      user_styles = Registry.get_inline_styles(:user)

      assert length(admin_styles) == 1
      assert length(user_styles) == 1
      assert hd(admin_styles).id == "abc12345"
      assert hd(user_styles).id == "def67890"
    end
  end

  describe "register_stylesheet/2" do
    test "registers stylesheet link" do
      assert Registry.register_stylesheet("/assets/card.css") == :ok
      links = Registry.get_stylesheet_links()
      assert length(links) == 1
      assert hd(links).href == "/assets/card.css"
    end

    test "deduplicates by href" do
      Registry.register_stylesheet("/assets/card.css")
      Registry.register_stylesheet("/assets/card.css")
      links = Registry.get_stylesheet_links()
      assert length(links) == 1
    end
  end

  describe "clear/1" do
    test "clears all namespaces" do
      Registry.register_inline(".test { color: red; }", "abc12345", namespace: :admin)
      Registry.register_inline(".test { color: blue; }", "def67890", namespace: :user)
      Registry.clear()

      assert Registry.get_inline_styles(:admin) == []
      assert Registry.get_inline_styles(:user) == []
    end

    test "clears specific namespace" do
      Registry.register_inline(".test { color: red; }", "abc12345", namespace: :admin)
      Registry.register_inline(".test { color: blue; }", "def67890", namespace: :user)
      Registry.clear(:admin)

      assert Registry.get_inline_styles(:admin) == []
      assert length(Registry.get_inline_styles(:user)) == 1
    end
  end
end
