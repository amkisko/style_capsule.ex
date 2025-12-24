defmodule PhoenixDemoWeb.Components.BlogPostCard do
  @moduledoc """
  Blog post card component using :blog namespace.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :blog, cache_strategy: :time

  @component_styles """
  .post-card {
    background: white;
    border-radius: 0.75rem;
    overflow: hidden;
    box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
    transition: all 0.3s ease;
    display: flex;
    flex-direction: column;
    height: 100%;
  }

  .post-card:hover {
    box-shadow: 0 8px 24px rgba(0, 0, 0, 0.15);
    transform: translateY(-4px);
  }

  .post-image {
    width: 100%;
    height: 200px;
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 3rem;
  }

  .post-content {
    padding: 1.5rem;
    flex: 1;
    display: flex;
    flex-direction: column;
  }

  .post-meta {
    display: flex;
    gap: 1rem;
    font-size: 0.875rem;
    color: #718096;
    margin-bottom: 0.75rem;
  }

  .post-tag {
    background: #edf2f7;
    padding: 0.25rem 0.75rem;
    border-radius: 0.25rem;
    font-size: 0.75rem;
    font-weight: 500;
    color: #4a5568;
  }

  .post-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1a202c;
    margin-bottom: 0.75rem;
    line-height: 1.3;
  }

  .post-excerpt {
    color: #4a5568;
    line-height: 1.6;
    margin-bottom: 1rem;
    flex: 1;
  }

  .post-link {
    color: #667eea;
    font-weight: 600;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
  }

  .post-link:hover {
    color: #5568d3;
  }

  .post-link::after {
    content: '→';
    transition: transform 0.2s;
  }

  .post-link:hover::after {
    transform: translateX(4px);
  }
  """

  attr :title, :string, required: true
  attr :excerpt, :string, required: true
  attr :author, :string, default: "Admin"
  attr :date, :string, default: nil
  attr :tag, :string, default: nil
  attr :href, :string, default: "#"

  def blog_post_card(assigns) do
    date = assigns.date || Date.utc_today() |> Date.to_string()

    assigns = assign(assigns, :date, date)

    ~H"""
    <.capsule module={__MODULE__}>
      <article class="post-card">
        <div class="post-image">📝</div>
        <div class="post-content">
          <div class="post-meta">
            <span><%= @author %></span>
            <span>•</span>
            <span><%= @date %></span>
            <%= if @tag do %>
              <span class="post-tag"><%= @tag %></span>
            <% end %>
          </div>
          <h3 class="post-title"><%= @title %></h3>
          <p class="post-excerpt"><%= @excerpt %></p>
          <a href={@href} class="post-link">Read more</a>
        </div>
      </article>
    </.capsule>
    """
  end
end
