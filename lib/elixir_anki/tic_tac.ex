defmodule ElixirAnki.TicTac do
  def start([mark1, mark2] = marks) when is_binary(mark1) and is_binary(mark2),
    do: [
      :ok,
      game:
        new()
        |> Map.merge(%{
          marks: marks,
          current_player: mark1
        })
    ]

  def move(
        %{
          marks: marks,
          positions: positions,
          current_player: mark
        } = game,
        mark,
        position
      ) do
    case {
      Enum.member?(marks, mark),
      positions
      |> unoccupied()
      |> Enum.member?(position)
    } do
      {false, _} ->
        [:unknown_player, game: game]

      {_, false} ->
        [:illegal_position, game: game]

      _ ->
        positions = Map.put(positions, position, mark)

        game = %{
          game
          | positions: positions,
            current_player: next_player(mark, marks)
        }

        case compute_winner(positions, marks) do
          nil ->
            unoccupied = unoccupied(positions)
            [:ok, unoccupied: unoccupied, game: game]

          {winner, occupied} ->
            [winner: winner, occupied: occupied, game: nil]
        end
    end
  end

  def move(game, _, _), do: [:wrong_player_turn, game: game]

  def next_player(player, players),
    do:
      players
      |> Enum.reject(&(&1 == player))
      |> hd()

  defp new(),
    do: %{
      positions:
        1..9
        |> Enum.map(&{&1, nil})
        |> Enum.into(%{}),
      marks: nil,
      current_player: nil
    }

  defp unoccupied(%{} = positions),
    do:
      Enum.reduce(positions, [], fn
        {k, nil}, acc -> [k | acc]
        _, acc -> acc
      end)

  defp compute_winner(%{} = positions, [mark1, mark2] = marks) do
    positions_1 = player_positions(positions, mark1)
    positions_2 = player_positions(positions, mark2)

    result =
      marks
      |> Enum.zip([positions_1, positions_2])
      |> Enum.into(%{})

    case won?(positions_1) do
      true ->
        {mark1, result}

      _ ->
        case won?(positions_2) do
          true -> {mark2, result}
          _ -> nil
        end
    end
  end

  defp player_positions(positions, mark),
    do:
      Enum.reduce(positions, [], fn
        {k, ^mark}, acc -> [k | acc]
        _, acc -> acc
      end)
      |> Enum.sort()

  defp won?(positions) when length(positions) < 3, do: false

  defp won?([current_pos | positions]) do
    diffs = [1, 2, 3, 4]

    diffs
    |> Enum.any?(&won?(positions, current_pos, &1, true))
  end

  defp won?([], _current_pos, _diff, acc), do: acc

  defp won?([next_pos | r], current_pos, diff, _)
       when next_pos - current_pos == diff,
       do: won?(r, next_pos, diff, true)

  defp won?(_, _, _, _), do: false
end
