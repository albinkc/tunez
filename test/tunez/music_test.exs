defmodule Tunez.MusicTest do
  use Tunez.DataCase, async: true
  alias Tunez.Music.Artist

  describe "artist queries" do
    test "can query artist sorted by name" do
      query_result =
        Artist
        |> Ash.Query.for_read(:read)
        |> Ash.Query.sort(name: :asc)
        |> Ash.Query.limit(1)
        |> Ash.read!()
        |> dbg()

      # print output of Ash.read!()
      # IO.inspect(query_result)

      assert is_list(query_result)
      assert length(query_result) == 1
    end
  end
end
