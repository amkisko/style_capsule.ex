defmodule PhoenixDemoWeb.Components.NotificationBadge do
  @moduledoc """
  Business case: Notification badge component.
  Shows alert/notification styling with different variants.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :app, cache_strategy: :none

  @component_styles """
  .notification {
    padding: 1rem 1.5rem;
    border-radius: 0.5rem;
    display: flex;
    align-items: flex-start;
    gap: 1rem;
    margin-bottom: 1rem;
    animation: slideIn 0.3s ease-out;
  }

  @keyframes slideIn {
    from {
      opacity: 0;
      transform: translateX(-20px);
    }
    to {
      opacity: 1;
      transform: translateX(0);
    }
  }

  .notification-icon {
    flex-shrink: 0;
    width: 1.5rem;
    height: 1.5rem;
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 0.875rem;
  }

  .notification-content {
    flex: 1;
  }

  .notification-title {
    font-weight: 600;
    margin-bottom: 0.25rem;
  }

  .notification-message {
    font-size: 0.875rem;
    opacity: 0.9;
  }

  .notification.success {
    background: #d1fae5;
    border-left: 4px solid #10b981;
  }

  .notification.success .notification-icon {
    background: #10b981;
    color: white;
  }

  .notification.success .notification-title {
    color: #065f46;
  }

  .notification.success .notification-message {
    color: #047857;
  }

  .notification.error {
    background: #fee2e2;
    border-left: 4px solid #ef4444;
  }

  .notification.error .notification-icon {
    background: #ef4444;
    color: white;
  }

  .notification.error .notification-title {
    color: #991b1b;
  }

  .notification.error .notification-message {
    color: #dc2626;
  }

  .notification.warning {
    background: #fef3c7;
    border-left: 4px solid #f59e0b;
  }

  .notification.warning .notification-icon {
    background: #f59e0b;
    color: white;
  }

  .notification.warning .notification-title {
    color: #92400e;
  }

  .notification.warning .notification-message {
    color: #d97706;
  }

  .notification.info {
    background: #dbeafe;
    border-left: 4px solid #3b82f6;
  }

  .notification.info .notification-icon {
    background: #3b82f6;
    color: white;
  }

  .notification.info .notification-title {
    color: #1e40af;
  }

  .notification.info .notification-message {
    color: #2563eb;
  }
  """

  attr :variant, :string, default: "info", values: ["success", "error", "warning", "info"]
  attr :title, :string, required: true
  attr :message, :string, default: nil
  attr :icon, :string, default: nil

  def notification_badge(assigns) do
    icon = assigns.icon || case assigns.variant do
      "success" -> "✓"
      "error" -> "✕"
      "warning" -> "⚠"
      "info" -> "ℹ"
    end

    assigns = assign(assigns, :icon, icon)

    ~H"""
    <.capsule module={__MODULE__}>
      <div class={"notification #{@variant}"}>
        <div class="notification-icon"><%= @icon %></div>
        <div class="notification-content">
          <div class="notification-title"><%= @title %></div>
          <%= if @message do %>
            <div class="notification-message"><%= @message %></div>
          <% end %>
        </div>
      </div>
    </.capsule>
    """
  end
end
