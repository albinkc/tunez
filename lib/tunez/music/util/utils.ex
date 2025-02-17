defmodule Tunez.Music.Util.Utils do
  def search(query) do
    query = String.downcase(query)

    load_all_artists()
    |> Enum.filter(fn %{name: name} ->
      name
      |> String.downcase()
      |> String.contains?(query)
    end)
  end

  def load_all_artists() do
    Tunez.Music.read_artists!()
  end
end
