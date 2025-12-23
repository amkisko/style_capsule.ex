defmodule PhoenixDemoWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, components and so on.

  This can be used in your application as:

      use PhoenixDemoWeb, :controller
      use PhoenixDemoWeb, :view
      use PhoenixDemoWeb, :live_view

  The definitions below will be executed for every view,
  component, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def html do
    quote do
      use Phoenix.Component

      unquote(html_helpers())
    end
  end

  def router do
    quote do
      use Phoenix.Router

      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router
    end
  end

  def live_view do
    quote do
      use Phoenix.LiveView,
        layout: {PhoenixDemoWeb.Layouts, :app}

      unquote(html_helpers())
    end
  end

  defp html_helpers do
    quote do
      # HTML escaping functionality
      import Phoenix.HTML
      import PhoenixDemoWeb.CoreComponents

      import Phoenix.LiveView.Helpers

      # Shortcut for generating JS commands
      alias Phoenix.LiveView.JS
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end

