defmodule PhoenixDemoWeb.Components.SettingsPanel do
  @moduledoc """
  Settings panel component using :settings namespace.
  """
  use Phoenix.Component
  use StyleCapsule.Component, namespace: :settings, strategy: :nesting

  @component_styles """
  .settings-panel {
    background: white;
    border-radius: 0.75rem;
    padding: 2rem;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
  }

  .settings-section {
    margin-bottom: 2rem;
  }

  .settings-section:last-child {
    margin-bottom: 0;
  }

  .settings-title {
    font-size: 1.5rem;
    font-weight: 700;
    color: #1a202c;
    margin-bottom: 1.5rem;
    padding-bottom: 1rem;
    border-bottom: 2px solid #e2e8f0;
  }

  .settings-group {
    margin-bottom: 1.5rem;
  }

  .settings-label {
    display: block;
    font-weight: 600;
    color: #1a202c;
    margin-bottom: 0.5rem;
  }

  .settings-description {
    font-size: 0.875rem;
    color: #718096;
    margin-bottom: 0.75rem;
  }

  .settings-input {
    width: 100%;
    padding: 0.75rem;
    border: 1px solid #e2e8f0;
    border-radius: 0.5rem;
    font-size: 1rem;
    transition: border-color 0.2s;
  }

  .settings-input:focus {
    outline: none;
    border-color: #667eea;
    box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
  }

  .settings-toggle {
    display: flex;
    align-items: center;
    gap: 0.75rem;
  }

  .settings-toggle-switch {
    position: relative;
    width: 3rem;
    height: 1.5rem;
    background: #cbd5e0;
    border-radius: 1rem;
    cursor: pointer;
    transition: background 0.2s;
  }

  .settings-toggle-switch.active {
    background: #667eea;
  }

  .settings-toggle-switch::after {
    content: '';
    position: absolute;
    top: 0.125rem;
    left: 0.125rem;
    width: 1.25rem;
    height: 1.25rem;
    background: white;
    border-radius: 50%;
    transition: transform 0.2s;
  }

  .settings-toggle-switch.active::after {
    transform: translateX(1.5rem);
  }

  .settings-button {
    background: #667eea;
    color: white;
    border: none;
    padding: 0.75rem 2rem;
    border-radius: 0.5rem;
    font-weight: 600;
    cursor: pointer;
    transition: background 0.2s;
  }

  .settings-button:hover {
    background: #5568d3;
  }
  """

  attr :title, :string, required: true
  slot :inner_block, required: true

  def settings_panel(assigns) do
    ~H"""
    <.capsule module={__MODULE__}>
      <div class="settings-panel">
        <h2 class="settings-title"><%= @title %></h2>
        <%= render_slot(@inner_block) %>
      </div>
    </.capsule>
    """
  end
end
