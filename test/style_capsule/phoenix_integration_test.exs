defmodule StyleCapsule.PhoenixIntegrationTest do
  use ExUnit.Case, async: false

  alias StyleCapsule.{Phoenix, Registry}

  setup do
    Registry.clear()
    :ok
  end

  describe "Phoenix integration" do
    test "register_inline and render_styles work together" do
      css = ".test { color: red; }"
      capsule_id = "abc12345"

      Phoenix.register_inline(css, capsule_id, namespace: :test)

      html = Phoenix.render_styles(namespace: :test)

      assert html =~ ~r/<style data-style-capsule="#{capsule_id}"/
      assert html =~ ~r/\[data-capsule="#{capsule_id}"\]/
      assert html =~ ".test"
    end

    test "register_stylesheet and render_styles work together" do
      href = "/assets/capsules/card.css"

      Phoenix.register_stylesheet(href, namespace: :test)

      html = Phoenix.render_styles(namespace: :test)

      assert html =~ ~r/<link rel="stylesheet" href="#{href}"/
    end

    test "render_styles handles multiple namespaces" do
      Phoenix.register_inline(".admin { color: blue; }", "admin12345", namespace: :admin)
      Phoenix.register_inline(".user { color: green; }", "user45678", namespace: :user)

      admin_html = Phoenix.render_styles(namespace: :admin)
      user_html = Phoenix.render_styles(namespace: :user)

      assert admin_html =~ "admin12345"
      assert admin_html =~ ".admin"
      refute admin_html =~ "user45678"

      assert user_html =~ "user45678"
      assert user_html =~ ".user"
      refute user_html =~ "admin12345"
    end

    test "register_inline uses cache strategy" do
      css = ".test { color: red; }"
      capsule_id = "cache12345"

      # First call should compute
      Phoenix.register_inline(css, capsule_id, namespace: :test, cache_strategy: :time, cache_ttl: 1000)

      # Second call with same CSS should use cache (doesn't break)
      Phoenix.register_inline(css, capsule_id, namespace: :test, cache_strategy: :time, cache_ttl: 1000)

      html = Phoenix.render_styles(namespace: :test)
      assert html =~ capsule_id
    end

    test "render_all_runtime_styles renders all namespaces" do
      # Register styles in multiple namespaces
      Phoenix.register_inline(".ns1 { color: red; }", "ns1_id123", namespace: :namespace1)
      Phoenix.register_inline(".ns2 { color: blue; }", "ns2_id456", namespace: :namespace2)
      Phoenix.register_inline(".ns3 { color: green; }", "ns3_id789", namespace: :namespace3)

      html = Phoenix.render_all_runtime_styles()

      # Should include all namespaces
      assert html =~ "ns1_id123"
      assert html =~ "ns2_id456"
      assert html =~ "ns3_id789"
      assert html =~ ".ns1"
      assert html =~ ".ns2"
      assert html =~ ".ns3"
    end

    test "render_all_runtime_styles returns empty when no styles" do
      Registry.clear()
      html = Phoenix.render_all_runtime_styles()
      assert html == ""
    end

    test "render_all_runtime_styles includes all cache strategies" do
      Registry.clear()

      # Register with different cache strategies
      Phoenix.register_inline(".none { color: red; }", "none_id12", namespace: :test, cache_strategy: :none)
      Phoenix.register_inline(".time { color: blue; }", "time_id34", namespace: :test, cache_strategy: :time)

      html = Phoenix.render_all_runtime_styles()

      # Both should be included (runtime strategies)
      assert html =~ "none_id12"
      assert html =~ "time_id34"
    end

    test "render_styles with empty namespace returns empty string" do
      Registry.clear()
      html = Phoenix.render_styles(namespace: :empty)
      assert html == ""
    end

    test "register_inline with different strategies" do
      css = ".test { color: red; }"
      capsule_id1 = "patch12345"
      capsule_id2 = "nest12345"

      Phoenix.register_inline(css, capsule_id1, namespace: :test, strategy: :patch)
      Phoenix.register_inline(css, capsule_id2, namespace: :test, strategy: :nesting)

      html = Phoenix.render_styles(namespace: :test)
      assert html =~ capsule_id1
      assert html =~ capsule_id2
    end

    test "register_inline with attrs" do
      css = ".test { color: red; }"
      capsule_id = "attrs12345"

      Phoenix.register_inline(css, capsule_id, namespace: :test, attrs: [media: "print"])

      html = Phoenix.render_styles(namespace: :test)
      assert html =~ ~r/media="print"/
    end

    test "register_stylesheet with attrs" do
      href = "/assets/capsules/card.css"

      Phoenix.register_stylesheet(href, namespace: :test, attrs: [media: "screen"])

      html = Phoenix.render_styles(namespace: :test)
      assert html =~ ~r/media="screen"/
    end

    test "precompiled_stylesheet_links returns list (may be empty or have existing files)" do
      links = Phoenix.precompiled_stylesheet_links()
      # May have existing build metadata from previous test runs
      assert is_list(links)
    end

    test "precompiled_stylesheet_links with namespace filter" do
      # This will be empty unless build metadata exists
      links = Phoenix.precompiled_stylesheet_links(namespace: :test)
      assert is_list(links)
    end

    test "precompiled_stylesheet_links with base_path" do
      links = Phoenix.precompiled_stylesheet_links(base_path: "/assets")
      assert is_list(links)
    end

    test "render_precompiled_stylesheets returns string (may be empty or have existing files)" do
      html = Phoenix.render_precompiled_stylesheets()
      # May have existing build metadata from previous test runs
      assert is_binary(html)
    end

    test "render_precompiled_stylesheets with namespace" do
      html = Phoenix.render_precompiled_stylesheets(namespace: :test)
      assert is_binary(html)
    end

    test "render_styles handles both inline and stylesheet links" do
      css = ".test { color: red; }"
      capsule_id = "mixed12345"
      href = "/assets/test.css"

      Phoenix.register_inline(css, capsule_id, namespace: :test)
      Phoenix.register_stylesheet(href, namespace: :test)

      html = Phoenix.render_styles(namespace: :test)

      assert html =~ capsule_id
      assert html =~ href
      assert html =~ "<style"
      assert html =~ "<link"
    end

    test "render_styles filters empty strings" do
      Registry.clear()
      html = Phoenix.render_styles(namespace: :test)
      assert html == ""
    end
  end
end
