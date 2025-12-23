defmodule PhoenixDemoWeb.Components.RootSelectorExample do
  use Phoenix.Component

  @component_styles """
  /* Root selector - targets only the wrapper element itself */
  :host {
    display: flex;
    flex-direction: column;
    gap: 1rem;
    padding: 1.5rem;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    border-radius: 0.75rem;
    color: white;
  }

  /* Regular descendant selectors */
  .label {
    font-size: 0.875rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
    opacity: 0.9;
  }

  .label::before {
    content: "RootSelector capsule (:host)";
    display: block;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    opacity: 0.85;
  }

  .value {
    font-size: 2rem;
    font-weight: 700;
  }

  .description {
    font-size: 0.875rem;
    opacity: 0.8;
    margin-top: 0.5rem;
  }
  """

  def root_selector_example(assigns) do
    assigns = assign(assigns, :label, Map.get(assigns, :label, "Metric"))
    assigns = assign(assigns, :value, Map.get(assigns, :value, "0"))
    assigns = assign(assigns, :description, Map.get(assigns, :description))

    capsule_id = StyleCapsule.capsule_id(__MODULE__)
    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id, namespace: :app)

    assigns = assign(assigns, :capsule_id, capsule_id)

    ~H"""
    <div data-capsule={@capsule_id}>
      <div class="label"><%= @label %></div>
      <div class="value"><%= @value %></div>
      <%= if @description do %>
        <div class="description"><%= @description %></div>
      <% end %>
    </div>
    """
  end
end
