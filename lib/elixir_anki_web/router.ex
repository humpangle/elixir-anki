defmodule ElixirAnkiWeb.Router do
  use ElixirAnkiWeb, :router
  use ExAdmin.Router

  pipeline :browser do
    plug(:accepts, ["html"])
    plug(:fetch_session)
    plug(:fetch_flash)
    plug(:protect_from_forgery)
    plug(:put_secure_browser_headers)
  end

  scope "/admin", ExAdmin do
    pipe_through(:browser)
    admin_routes()
  end

  pipeline :api do
    plug(:accepts, ["json"])
  end

  scope "/", ElixirAnkiWeb do
    # Use the default browser stack
    pipe_through(:browser)

    resources("/users", UserController)

    get("/", PageController, :index)
  end

  # Other scopes may use custom stacks.
  # scope "/api", ElixirAnkiWeb do
  #   pipe_through :api
  # end
end
