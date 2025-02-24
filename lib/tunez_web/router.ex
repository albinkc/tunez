defmodule TunezWeb.Router do
  use TunezWeb, :router

  use AshAuthentication.Phoenix.Router

  import AshAuthentication.Plug.Helpers

  pipeline :graphql do
    plug :load_from_bearer
    plug :set_actor, :user
    plug AshGraphql.Plug
  end

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TunezWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :load_from_session
  end

  pipeline :api do
    plug :accepts, ["json"]
    plug :load_from_bearer
    plug :set_actor, :user
  end

  pipeline :sse do
    plug :accepts, ["sse"]
    plug :ensure_session_id
  end

  scope "/" do
    pipe_through :sse
    get "/sse", SSE.ConnectionPlug, :call

    pipe_through :api
    post "/message", SSE.ConnectionPlug, :call
  end

  scope "/", TunezWeb do
    pipe_through :browser

    ash_authentication_live_session :authenticated_routes do
      # in each liveview, add one of the following at the top of the module:
      #
      # If an authenticated user must be present:
      # on_mount {TunezWeb.LiveUserAuth, :live_user_required}
      #
      # If an authenticated user *may* be present:
      # on_mount {TunezWeb.LiveUserAuth, :live_user_optional}
      #
      # If an authenticated user must *not* be present:
      # on_mount {TunezWeb.LiveUserAuth, :live_no_user}
      live "/", Artists.IndexLive
      live "/artists/new", Artists.FormLive, :new
      live "/artists/:id", Artists.ShowLive
      live "/artists/:id/edit", Artists.FormLive, :edit
      live "/artists/:artist_id/albums/new", Albums.FormLive, :new
      live "/albums/:id/edit", Albums.FormLive, :edit
    end
  end

  scope "/gql" do
    pipe_through [:graphql]

    forward "/playground",
            Absinthe.Plug.GraphiQL,
            schema: Module.concat(["TunezWeb.GraphqlSchema"]),
            interface: :playground

    forward "/",
            Absinthe.Plug,
            schema: Module.concat(["TunezWeb.GraphqlSchema"])
  end

  scope "/api/json" do
    pipe_through [:api]

    forward "/swaggerui",
            OpenApiSpex.Plug.SwaggerUI,
            path: "/api/json/open_api",
            default_model_expand_depth: 4

    forward "/", TunezWeb.AshJsonApiRouter
  end

  scope "/", TunezWeb do
    pipe_through :browser

    auth_routes AuthController, Tunez.Accounts.User, path: "/auth"
    sign_out_route AuthController

    # Remove these if you'd like to use your own authentication views
    sign_in_route register_path: "/register",
                  reset_path: "/reset",
                  auth_routes_prefix: "/auth",
                  on_mount: [{TunezWeb.LiveUserAuth, :live_no_user}],
                  overrides: [TunezWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]

    # Remove this if you do not want to use the reset password feature
    reset_route auth_routes_prefix: "/auth",
                overrides: [TunezWeb.AuthOverrides, AshAuthentication.Phoenix.Overrides.Default]
  end

  # Other scopes may use custom stacks.
  # scope "/api", TunezWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:tunez, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TunezWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  # Middleware to ensure session ID exists
  def ensure_session_id(conn, _opts) do
    case get_session_id(conn) do
      nil ->
        # Generate a new session ID if none exists
        session_id = generate_session_id()
        %{conn | query_params: Map.put(conn.query_params, "sessionId", session_id)}

      _session_id ->
        conn
    end
  end

  # Helper to get session ID from query params
  defp get_session_id(conn) do
    conn.query_params["sessionId"]
  end

  # Generate a unique session ID
  defp generate_session_id do
    Base.encode16(:crypto.strong_rand_bytes(8), case: :lower)
  end
end
