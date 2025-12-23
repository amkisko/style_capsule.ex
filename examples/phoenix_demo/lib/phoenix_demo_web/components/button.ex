defmodule PhoenixDemoWeb.Components.Button do
  use Phoenix.Component

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

  def button(assigns) do
    assigns = assign(assigns, :variant, Map.get(assigns, :variant, "primary"))

    capsule_id = StyleCapsule.capsule_id(__MODULE__)
    assigns = assign(assigns, :capsule_id, capsule_id)

    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id,
      namespace: :app,
      cache_strategy: :time,
      cache_ttl: 3600
    )

    ~H"""
    <div data-capsule={@capsule_id}>
      <button class={"button #{@variant}"} type={Map.get(assigns, :type, "button")}>
        <%= render_slot(@inner_block) %>
      </button>
    </div>
    """
  end
end
