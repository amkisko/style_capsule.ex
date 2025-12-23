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
  end
end
