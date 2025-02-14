defmodule Tunez.Repo.Migrations.AddAi do
  @moduledoc """
  Updates resources based on their most recent snapshots.

  This file was autogenerated with `mix ash_postgres.generate_migrations`
  """

  use Ecto.Migration

  def up do
    alter table(:albums) do
      add :vectorized_name, :vector
      add :full_text_vector, :vector
    end
  end

  def down do
    alter table(:albums) do
      remove :full_text_vector
      remove :vectorized_name
    end
  end
end
