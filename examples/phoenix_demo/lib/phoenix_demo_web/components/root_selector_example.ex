defmodule PhoenixDemoWeb.Components.RootSelectorExample do
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app

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

  attr :label, :string, default: "Metric"
  attr :value, :string, default: "0"
  attr :description, :string, default: nil

  def root_selector_example(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="label"><%= @label %></div>
      <div class="value"><%= @value %></div>
      <%= if @description do %>
        <div class="description"><%= @description %></div>
      <% end %>
    </.capsule>
    """
  end
end
