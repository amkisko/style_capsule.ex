defmodule PhoenixDemoWeb.Components.Button do
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app, cache_strategy: :time

  @component_styles """
  .button {
    display: inline-block;
    padding: 0.5rem 1rem;
    border-radius: 0.25rem;
    font-weight: 500;
    cursor: pointer;
    transition: all 0.2s;
    border: none;
  }

   .button::before {
     content: "Button capsule";
     display: inline-block;
     font-size: 0.75rem;
     text-transform: uppercase;
     letter-spacing: 0.08em;
     color: #a0aec0;
     margin-right: 0.5rem;
   }

  .button.primary {
    background: #3182ce;
    color: white;
  }

  .button.primary:hover {
    background: #2c5aa0;
  }

  .button.secondary {
    background: #e2e8f0;
    color: #2d3748;
  }

  .button.secondary:hover {
    background: #cbd5e0;
  }
  """

  attr :variant, :string, default: "primary"
  attr :type, :string, default: "button"
  slot :inner_block, required: true

  def button(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <button class={"button #{@variant}"} type={@type}>
        <%= render_slot(@inner_block) %>
      </button>
    </.capsule>
    """
  end
end
