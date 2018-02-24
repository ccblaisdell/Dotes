defmodule DotesWeb.Router do
  use Dotes.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DotesWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    
    get "/matches/delete_all", MatchController, :delete_all
    get "/matches/get_recent", MatchController, :get_recent
    resources "/matches", MatchController

    resources "/users", UserController
    get "/users/:id/get", UserController, :get
    get "/users/:id/get_all", UserController, :get_all
    
    post "/rolls/go", RollController, :go
    resources "/rolls", RollController
  end

  # Other scopes may use custom stacks.
  # scope "/api", Dotes do
  #   pipe_through :api
  # end
end
