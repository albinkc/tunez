defmodule TunezWeb.AuthOverrides do
  use AshAuthentication.Phoenix.Overrides
  alias AshAuthentication.Phoenix.Components

  # configure your UI overrides here

  # First argument to `override` is the component name you are overriding.
  # The body contains any number of configurations you wish to override
  # Below are some examples

  # For a complete reference, see https://hexdocs.pm/ash_authentication_phoenix/ui-overrides.html

  # override AshAuthentication.Phoenix.Components.Banner do
  #   set :image_url, "https://media.giphy.com/media/g7GKcSzwQfugw/giphy.gif"
  #   set :text_class, "bg-red-500"
  # end

  # override AshAuthentication.Phoenix.Components.SignIn do
  #  set :show_banner, false
  # end
  override Components.Banner do
    set :image_url, nil
    set :dark_image_url, nil
    set :text_class, "text-8xl text-accent"
    set :text, "♫"
  end

  override Components.Password do
    set :toggler_class, "flex-none text-primary px-2 first:pl-0 last:pr-0"
  end

  override Components.Password.Input do
    set :field_class, "form-control mt-4"
    set :label_class, "block label cursor-pointer"
    set :input_class, "input input-bordered w-full"
    set :input_class_with_error, "input input-bordered w-full input-error"
    set :submit_class, "phx-submit-loading:opacity-75 btn btn-primary my-4"
    set :error_ul, "mt-2 flex gap-2 text-sm leading-6 text-error"
  end

  override Components.MagicLink do
    set :request_flash_text, "Check your email for a sign-in link!"
  end

  override AshAuthentication.Phoenix.Components.Password.Input do
    set :submit_class, "phx-submit-loading:opacity-75 btn btn-primary"
  end
end
