defmodule StyleCapsule.PhlexComponentTest do
  use ExUnit.Case, async: false

  alias StyleCapsule.{CompileRegistry, PhlexComponent, Registry}

  # Check if Phlex is available
  @phlex_available Code.ensure_loaded?(Phlex.HTML)

  setup do
    # Clear registries before each test
    Registry.clear()
    CompileRegistry.clear()

    on_exit(fn ->
      Registry.clear()
      CompileRegistry.clear()
    end)

    :ok
  end

  describe "PhlexComponent.add_capsule_attrs" do
    test "add_capsule_attrs with list attrs" do
      attrs = [class: "test", id: "test-id"]
      module = StyleCapsule

      result = PhlexComponent.add_capsule_attrs(attrs, module)

      assert Keyword.has_key?(result, :"data-capsule")
      assert Keyword.get(result, :class) == "test"
      assert Keyword.get(result, :id) == "test-id"
    end

    test "add_capsule_attrs with map attrs" do
      attrs = %{"class" => "test", "id" => "test-id"}
      module = StyleCapsule

      result = PhlexComponent.add_capsule_attrs(attrs, module)

      assert Map.has_key?(result, "data-capsule")
      assert result["class"] == "test"
      assert result["id"] == "test-id"
    end

    test "add_capsule_attrs handles Phlex.StyleCapsule not available" do
      attrs = [class: "test"]
      module = StyleCapsule

      # Should fall back to direct method
      result = PhlexComponent.add_capsule_attrs(attrs, module)
      assert Keyword.has_key?(result, :"data-capsule")
    end

    test "add_capsule_attrs with other types returns unchanged" do
      attrs = :not_a_list_or_map
      module = StyleCapsule

      result = PhlexComponent.add_capsule_attrs(attrs, module)
      assert result == attrs
    end
  end

  # Phlex integration tests - only run when Phlex is available
  if @phlex_available do
    describe "PhlexComponent integration" do
      test "component with styles registers at compile time" do
        defmodule TestPhlexComponent do
          use PhlexComponent

          @component_styles """
          .test { color: red; }
          """

          defp render_template(_assigns, attrs, state) do
            Phlex.HTML.div(state, attrs, "Test")
          end
        end

        # Check that styles function is generated
        assert function_exported?(TestPhlexComponent, :styles, 0)
        assert TestPhlexComponent.styles() =~ ".test"

        # Check that style_capsule_spec is generated
        assert function_exported?(TestPhlexComponent, :style_capsule_spec, 0)
        spec = TestPhlexComponent.style_capsule_spec()
        assert spec.module == TestPhlexComponent
        assert spec.styles =~ ".test"
        assert spec.namespace == :default
        assert spec.strategy == :patch
        assert spec.cache_strategy == :none
      end

      test "component with custom namespace and strategy" do
        defmodule TestPhlexComponentCustom do
          use PhlexComponent, namespace: :admin, strategy: :nesting, cache_strategy: :time

          @component_styles """
          .admin { background: blue; }
          """

          defp render_template(_assigns, attrs, state) do
            Phlex.HTML.div(state, attrs, "Admin")
          end
        end

        spec = TestPhlexComponentCustom.style_capsule_spec()
        assert spec.namespace == :admin
        assert spec.strategy == :nesting
        assert spec.cache_strategy == :time
      end

      test "component without styles still works" do
        defmodule TestPhlexComponentNoStyles do
          use PhlexComponent

          defp render_template(_assigns, attrs, state) do
            Phlex.HTML.div(state, attrs, "No Styles")
          end
        end

        # Should still have styles/0 function (returns empty string)
        assert function_exported?(TestPhlexComponentNoStyles, :styles, 0)
        assert TestPhlexComponentNoStyles.styles() == ""

        # Should still have style_capsule_spec
        spec = TestPhlexComponentNoStyles.style_capsule_spec()
        assert spec.styles == ""
      end

      test "component renders with capsule attributes" do
        defmodule TestPhlexComponentRender do
          use PhlexComponent

          @component_styles """
          .test { padding: 1rem; }
          """

          defp render_template(_assigns, attrs, state) do
            Phlex.HTML.div(state, attrs, "Content")
          end
        end

        html = TestPhlexComponentRender.render(%{})
        assert html =~ "data-capsule"
        assert html =~ "Content"
      end

      test "component registers styles at runtime for :none cache strategy" do
        defmodule TestPhlexComponentRuntime do
          use PhlexComponent, cache_strategy: :none

          @component_styles """
          .runtime { color: green; }
          """

          defp render_template(_assigns, attrs, state) do
            Phlex.HTML.div(state, attrs, "Runtime")
          end
        end

        # Render to trigger runtime registration
        TestPhlexComponentRuntime.render(%{})

        # Check that styles were registered
        capsule_id = StyleCapsule.capsule_id(TestPhlexComponentRuntime)
        styles = Registry.get_inline_styles(:default)
        component_style = Enum.find(styles, fn s -> s.id == capsule_id end)

        assert component_style != nil
        assert component_style.css =~ ".runtime"
      end

      test "component registers styles at runtime for :time cache strategy" do
        defmodule TestPhlexComponentTime do
          use PhlexComponent, cache_strategy: :time

          @component_styles """
          .time { color: blue; }
          """

          defp render_template(_assigns, attrs, state) do
            Phlex.HTML.div(state, attrs, "Time")
          end
        end

        # Render to trigger runtime registration
        TestPhlexComponentTime.render(%{})

        # Check that styles were registered
        capsule_id = StyleCapsule.capsule_id(TestPhlexComponentTime)
        styles = Registry.get_inline_styles(:default)
        component_style = Enum.find(styles, fn s -> s.id == capsule_id end)

        assert component_style != nil
        assert component_style.css =~ ".time"
      end

      test "component does not register at runtime for :file cache strategy" do
        defmodule TestPhlexComponentFile do
          use PhlexComponent, cache_strategy: :file

          @component_styles """
          .file { color: red; }
          """

          defp render_template(_assigns, attrs, state) do
            Phlex.HTML.div(state, attrs, "File")
          end
        end

        # Render - should not register at runtime
        TestPhlexComponentFile.render(%{})

        # Check that styles were NOT registered at runtime
        capsule_id = StyleCapsule.capsule_id(TestPhlexComponentFile)
        styles = Registry.get_inline_styles(:default)
        component_style = Enum.find(styles || [], fn s -> s.id == capsule_id end)

        assert component_style == nil
      end

      test "component with assigns map extracts correctly" do
        defmodule TestPhlexComponentAssigns do
          use PhlexComponent

          @component_styles """
          .test { color: red; }
          """

          defp render_template(assigns, attrs, state) do
            title = Map.get(assigns, :title, "Default")
            Phlex.HTML.div(state, attrs, title)
          end
        end

        html = TestPhlexComponentAssigns.render(%{title: "Custom Title"})
        assert html =~ "Custom Title"
      end

      test "component with _assigns field uses it directly" do
        defmodule TestPhlexComponentDirectAssigns do
          use PhlexComponent

          @component_styles """
          .test { color: red; }
          """

          defp render_template(assigns, attrs, state) do
            title = Map.get(assigns, :title, "Default")
            # credo:disable-for-next-line
            Phlex.HTML.div(state, attrs, title)
          end
        end

        # Create component with _assigns
        component = struct(TestPhlexComponentDirectAssigns, %{_assigns: %{title: "From Assigns"}})

        # Phlex is optional, so we can't alias it - use full module path
        # credo:disable-for-next-line
        state = Phlex.SGML.State.new()
        html = TestPhlexComponentDirectAssigns.view_template(component, state)
        # credo:disable-for-next-line
        html_string = Phlex.SGML.State.flush(html) |> IO.iodata_to_binary()

        assert html_string =~ "From Assigns"
      end
    end
  end
end
