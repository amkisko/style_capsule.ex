defmodule PhoenixDemoWeb.Router do
  use PhoenixDemoWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {PhoenixDemoWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  scope "/", PhoenixDemoWeb do
    pipe_through :browser

    live "/", PageLive, :index
    live "/showcase", ShowcaseLive, :index
    live "/business", BusinessLive, :index
    live "/features", FeaturesLive, :index
    live "/namespaces", NamespacesLive, :index
  end
end
