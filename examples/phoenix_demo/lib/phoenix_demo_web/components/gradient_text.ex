defmodule PhoenixDemoWeb.Components.GradientText do
  @moduledoc """
  Text with animated gradient background.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .gradient-text {
    font-size: 3rem;
    font-weight: 700;
    background: linear-gradient(90deg, #667eea 0%, #764ba2 50%, #f093fb 100%);
    background-size: 200% auto;
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    animation: gradient-shift 3s ease infinite;
  }

  @keyframes gradient-shift {
    0% {
      background-position: 0% center;
    }
    100% {
      background-position: 200% center;
    }
  }

  .gradient-text.small {
    font-size: 1.5rem;
  }

  .gradient-text.large {
    font-size: 4rem;
  }
  """

  attr :size, :string, default: "medium", values: ["small", "medium", "large"]
  slot :inner_block, required: true

  def gradient_text(assigns) do
    size_class = cond do
      assigns.size == "small" -> "small"
      assigns.size == "large" -> "large"
      true -> ""
    end
    assigns = assign(assigns, :size_class, size_class)

    ~H"""
    <.capsule module={__MODULE__}>
      <div class={"gradient-text #{@size_class}"}>
        <%= render_slot(@inner_block) %>
      </div>
    </.capsule>
    """
  end
end
