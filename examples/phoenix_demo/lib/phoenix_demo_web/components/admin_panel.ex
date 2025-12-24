defmodule PhoenixDemoWeb.Components.AdminPanel do
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :admin, strategy: :nesting

  @component_styles """
  /* Root selector pattern - targets only the root element */
  :host {
    display: block;
    background: #fef3c7;
    border: 2px solid #f59e0b;
    border-radius: 0.5rem;
    padding: 1.5rem;
  }

  /* Descendant selectors work normally */
  .title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #92400e;
    margin-bottom: 1rem;
  }

  .title::before {
    content: "AdminPanel capsule (:admin, :nesting)";
    display: block;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: #b45309;
    margin-bottom: 0.25rem;
  }

  .content {
    color: #78350f;
    line-height: 1.6;
  }

  .warning {
    background: #fee2e2;
    border-left: 4px solid #dc2626;
    padding: 0.75rem;
    margin-top: 1rem;
    border-radius: 0.25rem;
  }
  """

  attr :title, :string, default: "Admin Panel"
  slot :inner_block, required: true

  def admin_panel(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <h2 class="title"><%= @title %></h2>
      <div class="content">
        <%= render_slot(@inner_block) %>
      </div>
      <div class="warning">
        ⚠️ This panel uses the <code>:admin</code> namespace and <code>:nesting</code> strategy.
      </div>
    </.capsule>
    """
  end
end
