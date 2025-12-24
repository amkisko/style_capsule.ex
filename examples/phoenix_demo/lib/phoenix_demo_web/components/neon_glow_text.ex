defmodule PhoenixDemoWeb.Components.NeonGlowText do
  @moduledoc """
  Neon glow text effect with animated shadows.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .neon-text {
    font-size: 3rem;
    font-weight: 700;
    color: #fff;
    text-align: center;
    text-transform: uppercase;
    letter-spacing: 0.1em;
    text-shadow:
      0 0 10px #0ff,
      0 0 20px #0ff,
      0 0 30px #0ff,
      0 0 40px #0ff,
      0 0 70px #0ff,
      0 0 80px #0ff;
    animation: neon-flicker 2s infinite alternate;
  }

  @keyframes neon-flicker {
    0%, 18%, 22%, 25%, 53%, 57%, 100% {
      text-shadow:
        0 0 10px #0ff,
        0 0 20px #0ff,
        0 0 30px #0ff,
        0 0 40px #0ff,
        0 0 70px #0ff,
        0 0 80px #0ff;
    }
    20%, 24%, 55% {
      text-shadow: none;
    }
  }

  .neon-text.pink {
    text-shadow:
      0 0 10px #ff00ff,
      0 0 20px #ff00ff,
      0 0 30px #ff00ff,
      0 0 40px #ff00ff,
      0 0 70px #ff00ff,
      0 0 80px #ff00ff;
  }

  .neon-text.pink {
    animation: neon-flicker-pink 2s infinite alternate;
  }

  @keyframes neon-flicker-pink {
    0%, 18%, 22%, 25%, 53%, 57%, 100% {
      text-shadow:
        0 0 10px #ff00ff,
        0 0 20px #ff00ff,
        0 0 30px #ff00ff,
        0 0 40px #ff00ff,
        0 0 70px #ff00ff,
        0 0 80px #ff00ff;
    }
    20%, 24%, 55% {
      text-shadow: none;
    }
  }
  """

  attr :color, :string, default: "cyan", values: ["cyan", "pink"]
  slot :inner_block, required: true

  def neon_glow_text(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class={"neon-text #{@color}"}>
        <%= render_slot(@inner_block) %>
      </div>
    </.capsule>
    """
  end
end
