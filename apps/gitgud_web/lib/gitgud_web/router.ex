defmodule GitGud.Web.Router do
  @moduledoc false
  use GitGud.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug AuthenticationPlug
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end


  scope "/", GitGud.Web do
    pipe_through :browser

    get "/login", AuthenticationController, :new
    post "/login", AuthenticationController, :create
    get "/logout", AuthenticationController, :delete

    scope "/:username" do
      get "/", UserProfileController, :show

      scope "/:repo_name" do
        get "/", RepositoryController, :show
        get "/tree/:spec/*path", RepositoryController, :tree
        get "/blob/:spec/*path", RepositoryController, :blob
      end
    end
  end

  scope "/:username/:repo_name", GitGud.Web do
    get "/info/refs", GitBackendController, :info_refs
    get "/HEAD", GitBackendController, :head
    post "/git-upload-pack", GitBackendController, :upload_pack
    post "/git-receive-pack", GitBackendController, :receive_pack
  end

  forward "/graphiql", Absinthe.Plug.GraphiQL, schema: GitGud.GraphQL.Schema
end
