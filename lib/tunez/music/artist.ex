defmodule Tunez.Music.Artist do
  use Ash.Resource, otp_app: :tunez, domain: Tunez.Music, data_layer: AshPostgres.DataLayer

  postgres do
    table "artists"
    repo Tunez.Repo

    custom_indexes do
      index "name gin_trgm_ops", name: "artists_name_gin_index", using: "GIN"
    end
  end

  actions do
    # defaults [:read, :destroy, :create, update: [:name, :biography]]
    defaults [:read, :destroy, :create]
    default_accept [:name, :biography]

    update :update do
      require_atomic? false
      accept [:name, :biography]
      change Tunez.Music.Changes.UpdatePreviousNames, where: [changing(:name)]
    end

    read :search do
      argument :query, :ci_string do
        constraints allow_empty?: true
        default ""
      end

      filter expr(contains(name, ^arg(:query)))
      # filter expr(1 == 1)
      pagination offset?: true, default_limit: 12
    end
  end

  attributes do
    uuid_v7_primary_key :id

    attribute :name, :string do
      allow_nil? false
      public? true
    end

    attribute :biography, :string

    attribute :previous_names, {:array, :string} do
      default []
    end

    create_timestamp :inserted_at, public?: true
    update_timestamp :updated_at, public?: true
  end

  relationships do
    has_many :albums, Tunez.Music.Album do
      sort year_released: :desc
    end
  end

  calculations do
    calculate :years_ago, :integer, expr(2025 - year_released)
    # calculate :album_count, :integer, expr(count(albums))
    # calculate :latest_album_year_released, :integer, expr(first(albums, field: :year_released))
    # calculate :cover_image_url, :string, expr(first(albums, field: :cover_image_url))
  end

  aggregates do
    count :album_count, :albums, public?: true
    first :latest_album_year_released, :albums, :year_released, public?: true
    first :cover_image_url, :albums, :cover_image_url
  end
end
