defmodule Tunez.Accounts do
  use Ash.Domain,
    otp_app: :tunez,
    extensions: [AshJsonApi.Domain]

  json_api do
    routes do
      base_route "/users", Tunez.Accounts.User do
        post :register_with_password do
          route "/register"

          metadata fn _subject, user, _request ->
            # IO.inspect("###########")
            # user_map = Map.from_struct(user) |> Map.drop([:__struct__, :__meta__])
            # IO.inspect(user_map, label: "User as map", width: 0, pretty: true)
            # IO.inspect("###########")
            %{token: user.__metadata__.token}
          end
        end

        post :sign_in_with_password do
          route "/sign_in"

          metadata fn _subject, user, _request ->
            %{token: user.__metadata__.token}
          end
        end
      end
    end
  end

  resources do
    resource Tunez.Accounts.Token
    resource Tunez.Accounts.User
  end
end
