defmodule PhoenixDemoWeb.Components.SupportTicket do
  @moduledoc """
  Support ticket component using :support namespace.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :support, strategy: :patch

  @component_styles """
  .ticket {
    background: white;
    border-left: 4px solid #3b82f6;
    border-radius: 0.5rem;
    padding: 1.5rem;
    margin-bottom: 1rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
    transition: all 0.2s;
  }

  .ticket:hover {
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  }

  .ticket.priority-high {
    border-left-color: #ef4444;
  }

  .ticket.priority-medium {
    border-left-color: #f59e0b;
  }

  .ticket.priority-low {
    border-left-color: #10b981;
  }

  .ticket-header {
    display: flex;
    justify-content: space-between;
    align-items: flex-start;
    margin-bottom: 1rem;
  }

  .ticket-id {
    font-size: 0.875rem;
    color: #718096;
    font-family: monospace;
  }

  .ticket-status {
    padding: 0.25rem 0.75rem;
    border-radius: 0.25rem;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
  }

  .ticket-status.open {
    background: #dbeafe;
    color: #1e40af;
  }

  .ticket-status.in-progress {
    background: #fef3c7;
    color: #92400e;
  }

  .ticket-status.resolved {
    background: #d1fae5;
    color: #065f46;
  }

  .ticket-title {
    font-size: 1.25rem;
    font-weight: 600;
    color: #1a202c;
    margin-bottom: 0.5rem;
  }

  .ticket-description {
    color: #4a5568;
    line-height: 1.6;
    margin-bottom: 1rem;
  }

  .ticket-meta {
    display: flex;
    gap: 1.5rem;
    font-size: 0.875rem;
    color: #718096;
    padding-top: 1rem;
    border-top: 1px solid #e2e8f0;
  }
  """

  attr :id, :string, required: true
  attr :title, :string, required: true
  attr :description, :string, required: true
  attr :status, :string, default: "open", values: ["open", "in-progress", "resolved"]
  attr :priority, :string, default: "medium", values: ["high", "medium", "low"]
  attr :created_at, :string, default: nil
  attr :assignee, :string, default: nil

  def support_ticket(assigns) do
    created_at = assigns.created_at || Date.utc_today() |> Date.to_string()

    assigns = assign(assigns, :created_at, created_at)

    ~H"""
    <.capsule module={__MODULE__}>
      <div class={"ticket priority-#{@priority}"}>
        <div class="ticket-header">
          <span class="ticket-id">#<%= @id %></span>
          <span class={"ticket-status #{@status}"}><%= String.replace(@status, "-", " ") %></span>
        </div>
        <h3 class="ticket-title"><%= @title %></h3>
        <p class="ticket-description"><%= @description %></p>
        <div class="ticket-meta">
          <span>Created: <%= @created_at %></span>
          <%= if @assignee do %>
            <span>Assignee: <%= @assignee %></span>
          <% end %>
        </div>
      </div>
    </.capsule>
    """
  end
end
