defmodule PhoenixDemoWeb.CoreComponents do
  @moduledoc """
  Provides core UI components.
  """
  use Phoenix.Component

  @doc """
  Renders flash notices.
  """
  attr :flash, :map, required: true, doc: "the map of flash messages"
  attr :kind, :string, default: nil

  def flash_group(assigns) do
    ~H"""
    <div id="flash-group" phx-click={Phoenix.LiveView.JS.push("lv:clear-flash")} phx-key="Escape">
      <div :for={{kind, message} <- @flash} class={["alert", "alert-#{kind}"]}>
        <%= message %>
      </div>
    </div>
    """
  end
end

