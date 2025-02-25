defmodule TunezWeb.AshJsonApiRouter do
  use AshJsonApi.Router,
    domains: [Module.concat(["Tunez.Music"])],
    open_api: "/open_api"
end
