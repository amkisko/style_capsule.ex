defmodule PhoenixDemoWeb.Components.Card do
  use Phoenix.Component

  @component_styles """
  .root {
    padding: 1.5rem;
    border: 1px solid #e2e8f0;
    border-radius: 0.5rem;
    background: white;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .root::before {
    content: "Card capsule (inline styles)";
    display: block;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: #718096;
    margin-bottom: 0.5rem;
  }

  .heading {
    font-size: 1.25rem;
    font-weight: 600;
    margin-bottom: 0.75rem;
    color: #1a202c;
  }

  .content {
    color: #4a5568;
    line-height: 1.6;
  }
  """

  def card(assigns) do
    assigns = assign(assigns, :heading, Map.get(assigns, :heading))

    capsule_id = StyleCapsule.capsule_id(__MODULE__)
    assigns = assign(assigns, :capsule_id, capsule_id)

    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id, namespace: :app)

    ~H"""
    <div data-capsule={@capsule_id} class="root">
      <%= if @heading do %>
        <h2 class="heading"><%= @heading %></h2>
      <% end %>
      <div class="content">
        <%= render_slot(@inner_block) %>
      </div>
    </div>
    """
  end
end
