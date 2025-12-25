defmodule StyleCapsule.ConfigTest do
  use ExUnit.Case, async: true

  alias StyleCapsule.Config

  describe "track_component_renders?/0" do
    test "returns false by default" do
      # Clear any existing config
      Application.delete_env(:style_capsule, :track_component_renders)

      assert Config.track_component_renders?() == false
    end

    test "returns configured value" do
      Application.put_env(:style_capsule, :track_component_renders, true)
      assert Config.track_component_renders?() == true

      Application.put_env(:style_capsule, :track_component_renders, false)
      assert Config.track_component_renders?() == false

      # Clean up
      Application.delete_env(:style_capsule, :track_component_renders)
    end
  end
end
