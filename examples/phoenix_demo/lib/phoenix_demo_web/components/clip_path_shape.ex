defmodule PhoenixDemoWeb.Components.ClipPathShape do
  @moduledoc """
  Component using CSS clip-path for custom shapes.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

  @component_styles """
  .clip-shape {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    padding: 3rem 2rem;
    color: white;
    clip-path: polygon(0 0, 100% 0, 100% 85%, 0 100%);
    transition: clip-path 0.3s ease;
  }

  .clip-shape:hover {
    clip-path: polygon(0 0, 100% 0, 100% 90%, 0 100%);
  }

  .clip-shape.star {
    clip-path: polygon(50% 0%, 61% 35%, 98% 35%, 68% 57%, 79% 91%, 50% 70%, 21% 91%, 32% 57%, 2% 35%, 39% 35%);
  }

  .clip-shape.hexagon {
    clip-path: polygon(30% 0%, 70% 0%, 100% 50%, 70% 100%, 30% 100%, 0% 50%);
  }

  .clip-shape-content {
    text-align: center;
  }
  """

  attr :shape, :string, default: "polygon", values: ["polygon", "star", "hexagon"]
  slot :inner_block, required: true

  def clip_path_shape(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class={"clip-shape #{@shape}"}>
        <div class="clip-shape-content">
          <%= render_slot(@inner_block) %>
        </div>
      </div>
    </.capsule>
    """
  end
end
