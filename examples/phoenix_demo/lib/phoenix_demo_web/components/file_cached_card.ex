defmodule PhoenixDemoWeb.Components.FileCachedCard do
  use Phoenix.Component

  @component_styles """
  .file-cached-root {
    padding: 1.5rem;
    border: 2px dashed #10b981;
    border-radius: 0.5rem;
    background: #ecfdf5;
  }

  .file-cached-heading {
    font-size: 1.25rem;
    font-weight: 600;
    margin-bottom: 0.75rem;
    color: #065f46;
  }

  .file-cached-heading::before {
    content: "FileCachedCard capsule (:file cache)";
    display: block;
    font-size: 0.75rem;
    text-transform: uppercase;
    letter-spacing: 0.08em;
    color: #047857;
    margin-bottom: 0.25rem;
  }

  .file-cached-content {
    color: #047857;
    line-height: 1.6;
  }

  .file-cached-badge {
    display: inline-block;
    background: #10b981;
    color: white;
    padding: 0.25rem 0.75rem;
    border-radius: 0.25rem;
    font-size: 0.875rem;
    font-weight: 500;
    margin-top: 0.5rem;
  }
  """

  def file_cached_card(assigns) do
    assigns = assign(assigns, :heading, Map.get(assigns, :heading))

    capsule_id = StyleCapsule.capsule_id(__MODULE__)
    # Using :file cache strategy - styles will be written to files
    StyleCapsule.Phoenix.register_inline(@component_styles, capsule_id,
      namespace: :app,
      cache_strategy: :file
    )

    # Also register a stylesheet link pointing at the generated file so users
    # can see file-based caching in action once `mix style_capsule.build` runs.
    # Default output_dir is `priv/static/capsules`, served under "/capsules".
    StyleCapsule.Phoenix.register_stylesheet("/capsules/capsule-#{capsule_id}.css",
      namespace: :app,
      attrs: [data_capsule: capsule_id]
    )

    assigns = assign(assigns, :capsule_id, capsule_id)

    ~H"""
    <div data-capsule={@capsule_id} class="file-cached-root">
      <%= if @heading do %>
        <h2 class="file-cached-heading"><%= @heading %></h2>
      <% end %>
      <div class="file-cached-content">
        <%= render_slot(@inner_block) %>
      </div>
      <span class="file-cached-badge">File-cached</span>
    </div>
    """
  end
end
