defmodule ElixirAnki.Sql do
  import Ecto.Query, warn: false

  alias ElixirAnki.Repo
  alias ElixirAnki.HighSchooler
  alias ElixirAnki.HighSchoolerApi
  alias ElixirAnki.Friend
  alias ElixirAnki.FriendApi
  alias ElixirAnki.Like
  alias ElixirAnki.LikeApi
  alias ElixirAnki.Movie
  alias ElixirAnki.MovieApi
  alias ElixirAnki.Reviewer
  alias ElixirAnki.ReviewerApi
  alias ElixirAnki.Rating
  alias ElixirAnki.RatingApi
  alias ElixirAnki.DateRange
  alias ElixirAnki.DateRangeApi

  @high_schoolers [
    %{grade: "12", id: "1661", name: "Logan"},
    %{grade: "12", id: "1934", name: "Kyle"},
    %{grade: "12", id: "1025", name: "John"},
    %{grade: "12", id: "1304", name: "Jordan"},
    %{grade: "11", id: "1501", name: "Jessica"},
    %{grade: "11", id: "1911", name: "Gabriel"},
    %{grade: "11", id: "1316", name: "Austin"},
    %{grade: "11", id: "1247", name: "Alexis"},
    %{grade: "10", id: "1641", name: "Brittany"},
    %{grade: "10", id: "1468", name: "Kris"},
    %{grade: "10", id: "1782", name: "Andrew"},
    %{grade: "10", id: "1101", name: "Haley"},
    %{grade: "9", id: "1709", name: "Cassandra"},
    %{grade: "9", id: "1381", name: "Tiffany"},
    %{grade: "9", id: "1689", name: "Gabriel"},
    %{grade: "9", id: "1510", name: "Jordan"}
  ]

  @friends [
    %{id1: "1661", id2: "1025"},
    %{id1: "1304", id2: "1661"},
    %{id1: "1934", id2: "1304"},
    %{id1: "1316", id2: "1934"},
    %{id1: "1501", id2: "1934"},
    %{id1: "1911", id2: "1501"},
    %{id1: "1247", id2: "1501"},
    %{id1: "1247", id2: "1911"},
    %{id1: "1101", id2: "1641"},
    %{id1: "1468", id2: "1641"},
    %{id1: "1468", id2: "1101"},
    %{id1: "1782", id2: "1304"},
    %{id1: "1782", id2: "1316"},
    %{id1: "1782", id2: "1468"},
    %{id1: "1689", id2: "1782"},
    %{id1: "1709", id2: "1247"},
    %{id1: "1381", id2: "1247"},
    %{id1: "1689", id2: "1709"},
    %{id1: "1510", id2: "1689"},
    %{id1: "1510", id2: "1381"}
  ]

  @likes [
    %{id1: "1025", id2: "1101"},
    %{id1: "1934", id2: "1501"},
    %{id1: "1501", id2: "1934"},
    %{id1: "1316", id2: "1304"},
    %{id1: "1641", id2: "1468"},
    %{id1: "1247", id2: "1468"},
    %{id1: "1911", id2: "1247"},
    %{id1: "1782", id2: "1709"},
    %{id1: "1709", id2: "1689"},
    %{id1: "1689", id2: "1709"}
  ]

  @movies [
    %{
      director: "Steven Spielberg",
      mid: "108",
      title: "Raiders of the Lost Ark",
      year: "1981"
    },
    %{director: "James Cameron", mid: "107", title: "Avatar", year: "2009"},
    %{director: nil, mid: "106", title: "Snow White", year: "1937"},
    %{director: "James Cameron", mid: "105", title: "Titanic", year: "1997"},
    %{director: "Steven Spielberg", mid: "104", title: "E.T.", year: "1982"},
    %{
      director: "Robert Wise",
      mid: "103",
      title: "The Sound of Music",
      year: "1965"
    },
    %{director: "George Lucas", mid: "102", title: "Star Wars", year: "1977"},
    %{
      director: "Victor Fleming",
      mid: "101",
      title: "Gone with the Wind",
      year: "1939"
    }
  ]

  @reviewers [
    %{name: "Sarah Martinez", rid: "201"},
    %{name: "Daniel Lewis", rid: "202"},
    %{name: "Brittany Harris", rid: "203"},
    %{name: "Mike Anderson", rid: "204"},
    %{name: "Chris Jackson", rid: "205"},
    %{name: "Elizabeth Thomas", rid: "206"},
    %{name: "James Cameron", rid: "207"},
    %{name: "Ashley White", rid: "208"}
  ]

  @ratings [
    %{mid: "101", ratingdate: "2011-01-22", rid: "201", stars: "2"},
    %{mid: "101", ratingdate: "2011-01-27", rid: "201", stars: "4"},
    %{mid: "106", ratingdate: nil, rid: "202", stars: "4"},
    %{mid: "103", ratingdate: "2011-01-20", rid: "203", stars: "2"},
    %{mid: "108", ratingdate: "2011-01-12", rid: "203", stars: "4"},
    %{mid: "108", ratingdate: "2011-01-30", rid: "203", stars: "2"},
    %{mid: "101", ratingdate: "2011-01-09", rid: "204", stars: "3"},
    %{mid: "103", ratingdate: "2011-01-27", rid: "205", stars: "3"},
    %{mid: "104", ratingdate: "2011-01-22", rid: "205", stars: "2"},
    %{mid: "108", ratingdate: nil, rid: "205", stars: "4"},
    %{mid: "107", ratingdate: "2011-01-15", rid: "206", stars: "3"},
    %{mid: "106", ratingdate: "2011-01-19", rid: "206", stars: "5"},
    %{mid: "107", ratingdate: "2011-01-20", rid: "207", stars: "5"},
    %{mid: "104", ratingdate: "2011-01-02", rid: "208", stars: "3"}
  ]

  @ranges [
    {{2016, 1, 31}, {2016, 2, 12}},
    {{2016, 2, 1}, {2016, 2, 4}},
    {{2016, 2, 3}, {2016, 2, 4}},
    {{2016, 2, 12}, {2016, 2, 16}},
    {{2016, 2, 28}, {2016, 3, 10}},
    {{2016, 3, 3}, {2016, 3, 7}},
    {{2016, 4, 1}, {2016, 4, 9}},
    {{2016, 4, 6}, {2016, 4, 12}},
    {{2016, 4, 21}, {2016, 4, 25}},
    {{2016, 5, 1}, {2016, 5, 5}},
    {{2016, 5, 7}, {2016, 5, 8}},
    {{2016, 5, 8}, {2016, 5, 8}}
  ]

  @query_plan_regex ~r/^([^:]+)[^\d]+([\S]+)/
  @query_plan_key "QUERY PLAN"
  @spaces_for_column 2

  @empty_lines "\n\n\n\n"

  def load do
    [
      HighSchooler,
      Friend,
      Like,
      Rating,
      Movie,
      Reviewer,
      DateRange
    ]
    |> Enum.each(&Repo.delete_all/1)

    Repo.transaction(fn ->
      [
        {@high_schoolers, HighSchoolerApi},
        {@friends, FriendApi},
        {@likes, LikeApi},
        {@movies, MovieApi},
        {@reviewers, ReviewerApi},
        {@ratings, RatingApi}
      ]
      |> Enum.each(fn {data_list, mod} ->
        Enum.each(data_list, &apply(mod, :create_, [&1]))
      end)

      Enum.each(@ranges, fn {start, end_} ->
        DateRangeApi.create_(%{
          start: Ecto.Date.from_erl(start),
          end: Ecto.Date.from_erl(end_)
        })
      end)
    end)
  end

  def dsl do
    []
    # |> get_duplicates()
    |> display_table()
  end

  def sql do
    "
    "
    |> Repo.execute_and_load()
    # |> get_duplicates()
    |> display_table()
  end

  defp display_table([]), do: []

  defp display_table([%{@query_plan_key => _} | rest]) do
    {total_time, rows} =
      rest
      |> Enum.reverse()
      |> Enum.take(2)
      |> Enum.reduce({0, []}, fn row, {sum, acc} ->
        case Regex.run(@query_plan_regex, Map.get(row, @query_plan_key, "")) do
          [_, text, time] ->
            {
              sum + String.to_float(time),
              [%{"type" => text, "time" => time} | acc]
            }

          _ ->
            {sum, acc}
        end
      end)

    rows
    |> Enum.concat([
      %{
        "type" => "total",
        "time" => total_time
      }
    ])
    |> display_table()
  end

  defp display_table([header | _tail] = rows) when is_list(rows) do
    header = [
      "S/N"
      | Enum.map(header, fn {key, _val} -> String.upcase(key) end)
    ]

    rows =
      rows
      |> Enum.with_index(1)
      |> Enum.map(fn {data, index} ->
        [
          inspect(index)
          | Map.values(data) |> Enum.map(&value_to_string/1)
        ]
      end)

    rows = [header | rows]
    sizes = get_max_cols(rows)

    # each cell is padded with @spaces_for_column on both left and right
    # followed by '|' for a total len of (@spaces_for_column * 2) + 1 per cell
    # and an extra '|' at the end of each row
    dashes = Enum.sum(sizes) + length(sizes) * (@spaces_for_column * 2 + 1) + 1
    horizontal_line = [Enum.map(1..dashes, fn _ -> "-" end), "\n"]

    rows = Enum.map(rows, &["|", make_row(sizes, &1), "\n", horizontal_line])
    IO.puts([@empty_lines, horizontal_line, rows, @empty_lines])
  end

  defp display_table(rows) do
    IO.puts(@empty_lines)
    rows
  end

  defp make_row(sizes, columns) do
    sizes
    |> Enum.zip(columns)
    |> Enum.map(fn {size, col} ->
      [
        String.duplicate(" ", @spaces_for_column),
        col,
        String.duplicate(" ", size - String.length(col) + @spaces_for_column),
        "|"
      ]
    end)
  end

  defp get_max_cols(rows) do
    Enum.reduce(rows, [], fn
      row, [] ->
        Enum.map(row, &String.length/1)

      row, acc ->
        Enum.map(row, &String.length/1)
        |> Enum.zip(acc)
        |> Enum.map(fn {row_len, acc_len} ->
          max(row_len, acc_len)
        end)
    end)
  end

  defp value_to_string({year, month, day})
       when is_integer(year) and is_integer(month) and is_integer(day) do
    month = String.pad_leading("#{month}", 2, "0")
    day = String.pad_leading("#{day}", 2, "0")
    "#{year}-#{month}-#{day}"
  end

  defp value_to_string(val), do: "#{val}"

  def get_duplicates(rows) do
    rows
    |> Enum.reduce([[], []], fn row, [seen, all] ->
      if Enum.member?(all, row) do
        [[row | seen], all]
      else
        [seen, [row | all]]
      end
    end)
    |> hd()
  end
end
