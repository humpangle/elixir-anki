defmodule ElixirAnki.RandMod do
  @ascii_code_points Enum.concat(?a..?z, ?A..?Z)
  @number_code_points '0123456789'
  @under_score_code_point ?_
  @dash_code_point ?-
  @dot_code_point ?.
  @at_code_point ?@

  @before_at Enum.concat([
               @number_code_points,
               @ascii_code_points,
               [
                 @dash_code_point,
                 @under_score_code_point,
                 @dot_code_point
               ]
             ])

  @before_dot Enum.concat([
                @number_code_points,
                @ascii_code_points,
                [
                  @dash_code_point,
                  @under_score_code_point
                ]
              ])

  @just_before_dot Enum.concat(@ascii_code_points, @number_code_points)

  def start do
    num_lines =
      IO.gets("Enter number of lines: ")
      |> String.trim()
      |> String.to_integer()

    lines =
      1..num_lines
      |> Enum.map(fn l ->
        IO.gets("Enter code_points lines #{l} of #{num_lines}: ")
        |> String.trim()
      end)

    Enum.each(lines, &IO.puts(alternating_charlist(&1)))
  end

  def alternating_charlist(str),
    do:
      str
      |> String.to_charlist()
      |> alternating_charlist_p(-1, 0)

  defp alternating_charlist_p([], _, count), do: count

  defp alternating_charlist_p([first | rest], first, global_count) do
    alternating_charlist_p(rest, first, global_count + 1)
  end

  defp alternating_charlist_p([first | rest], _current, global_count) do
    alternating_charlist_p(rest, first, global_count)
  end

  def alternating_binary(str), do: alternating_binary_p(str, "", 0)
  defp alternating_binary_p("", _, count), do: count

  defp alternating_binary_p(<<first::utf8, rest::binary>>, first, count) do
    alternating_binary_p(rest, first, count + 1)
  end

  defp alternating_binary_p(<<first::utf8, rest::binary>>, _current, count) do
    alternating_binary_p(rest, first, count)
  end

  def le(list) when is_list(list), do: le(list, [])
  def le([], acc), do: Enum.reverse(acc)

  def le([a | rest], [{a, count} | acc]),
    do: le(rest, [{a, count + 1} | acc])

  def le([a, a | rest], acc), do: le(rest, [{a, 2} | acc])
  def le([a | rest], acc), do: le(rest, [a | acc])

  def rle do
    list = [4, 3, 3, 3, 9, 8, 8, 8, 8, 8, 1, 1, 7, 7, 7, 9]

    list
    |> le()
    |> inspect()
    |> IO.puts()
  end

  def parse_email(email) when is_binary(email) do
    initial_state = %{
      before_at: [],
      at: [],
      before_dot: [],
      dot: [],
      after_dot: []
    }

    email
    |> :binary.bin_to_list()
    |> do_parse_email({:before_at, initial_state})
  end

  defp do_parse_email(%{
         before_at: before_at,
         at: at,
         before_dot: before_dot,
         dot: dot,
         after_dot: after_dot
       }) do
    [before_at, at, before_dot, dot, after_dot]
    |> Enum.flat_map(&Enum.reverse/1)
    |> Enum.map(&<<&1>>)
    |> Enum.join()
  end

  defp do_parse_email(
         [],
         {_,
          %{
            before_at: before_at,
            at: at,
            before_dot: before_dot,
            dot: dot,
            after_dot: after_dot
          } = state}
       )
       when length(before_at) >= 1 and length(at) == 1 and length(before_dot) >= 1 and
              length(dot) == 1 and length(after_dot) >= 1,
       do: do_parse_email(state)

  #  at -> before_dot
  # we can only pick up '@' if we have seen at least one 'before at' chars
  # .i.e. length(code_points.before_at) >= 1
  #
  # and '@' chars i.e. code_points.at == []
  #
  # '@' must also be immediately followed by at least one non '.' char
  # and then other chars i.e length(rest) > 0
  defp do_parse_email(
         [@at_code_point, code_point | rest],
         {:before_at, %{before_at: before_at, at: []} = code_points}
       )
       when code_point in @just_before_dot and length(before_at) >= 1 and length(rest) > 0 do
    before_dot = [code_point | code_points.before_dot]
    at = [@at_code_point]

    code_points = %{
      code_points
      | before_dot: before_dot,
        at: at
    }

    print(
      {:at, :before_dot, <<@at_code_point>>, <<code_point>>, rest, do_parse_email(code_points)}
    )

    do_parse_email(rest, {:before_dot, code_points})
  end

  # at -> ..... -> at
  # if we see a '@' after consuming a '@', we fail.
  defp do_parse_email([@at_code_point | _], {_, %{at: [_ | _]}}),
    do: nil

  #  before_at -> before_at
  # at must be empty i.e. code_points.at == []
  #
  # and we mustn't have reached end of input i.e length(rest) > 0
  defp do_parse_email(
         [code_point | rest],
         {:before_at, %{at: []} = code_points}
       )
       when code_point in @before_at and length(rest) > 0 do
    code_points = %{
      code_points
      | before_at: [code_point | code_points.before_at]
    }

    print({:before_at, :before_at, <<code_point>>, rest, do_parse_email(code_points)})
    do_parse_email(rest, {:before_at, code_points})
  end

  # before_dot -> dot -> after_dot
  # a letter must immediately follow a dot
  # we must have consumed:
  # 1. exactly one '@'
  # 2. at least one before_at
  # 3. at least one before_dot
  # 4. not dot
  defp do_parse_email(
         [@dot_code_point, code_point | rest],
         {
           :before_dot,
           %{
             at: [@at_code_point],
             before_at: [_ | _],
             before_dot: [_ | _],
             dot: []
           } = code_points
         }
       )
       when code_point in @just_before_dot do
    code_points = %{
      code_points
      | dot: [@dot_code_point],
        after_dot: [code_point | code_points.after_dot]
    }

    print(
      {:before_dot, :dot, :after_dot, [<<@dot_code_point>>, <<code_point>>], rest,
       do_parse_email(code_points)}
    )

    do_parse_email(
      rest,
      {:after_dot, code_points}
    )
  end

  # before_dot -> before_dot
  # dot must be empty
  # we must have consumed exactly one '@'
  # we must have consumed at least one before_at
  # we must not have reached end of input
  defp do_parse_email(
         [code_point | rest],
         {:before_dot,
          %{
            before_at: [_ | _],
            at: [@at_code_point],
            dot: []
          } = code_points}
       )
       when code_point in @before_dot and length(rest) > 0 do
    code_points = %{
      code_points
      | before_dot: [code_point | code_points.before_dot]
    }

    print({:before_dot, :before_dot, <<code_point>>, rest, do_parse_email(code_points)})
    do_parse_email(rest, {:before_dot, code_points})
  end

  # after_dot -> last input char
  defp do_parse_email(
         [code_point | []],
         {
           :after_dot,
           %{
             before_at: [_ | _],
             at: [@at_code_point],
             before_dot: [_ | _],
             dot: [@dot_code_point]
           } = code_points
         }
       )
       when code_point in @just_before_dot do
    code_points = Map.update!(code_points, :after_dot, &[code_point | &1])

    print({:after_dot, :_, [], do_parse_email(code_points)})
    do_parse_email([], {:done, code_points})
  end

  # after_dot -> after_dot
  defp do_parse_email(
         [code_point | rest],
         {
           :after_dot,
           %{
             before_at: [_ | _],
             at: [@at_code_point],
             before_dot: [_ | _],
             dot: [@dot_code_point]
           } = code_points
         }
       )
       when code_point in @before_at and length(rest) > 0 do
    code_points = Map.update!(code_points, :after_dot, &[code_point | &1])

    print({:after_dot, :after_dot, rest, do_parse_email(code_points)})
    do_parse_email(rest, {:after_dot, code_points})
  end

  defp do_parse_email(code_points, matcher) do
    print({:no_match, code_points, matcher})
    nil
  end

  defp print(x), do: IO.puts(["\n", inspect(x)])
end
