defmodule ElixirAnki.TicTacTest do
  use ExUnit.Case, async: true
  alias ElixirAnki.TicTac

  test "player wins diagonally from left" do
    players = ["a", "b"]
    game = TicTac.start(players)

    assert [winner: "a", occupied: occupied, game: nil] =
             [1, 2, 5, 3, 9]
             |> Enum.reduce([game, "a"], fn pos, [game, player] ->
               [
                 game
                 |> Keyword.fetch!(:game)
                 |> TicTac.move(player, pos),
                 TicTac.next_player(player, players)
               ]
             end)
             |> hd()

    assert occupied["a"] == [1, 5, 9]
  end

  test "player wins diagonally from right" do
    players = ["a", "b"]
    game = TicTac.start(players)

    assert [winner: "a", occupied: occupied, game: nil] =
             [3, 2, 7, 1, 5]
             |> Enum.reduce([game, "a"], fn pos, [game, player] ->
               [
                 game
                 |> Keyword.fetch!(:game)
                 |> TicTac.move(player, pos),
                 TicTac.next_player(player, players)
               ]
             end)
             |> hd()

    assert occupied["a"] == [3, 5, 7]
  end

  test "player wins row" do
    players = ["a", "b"]
    game = TicTac.start(players)

    assert [winner: "a", occupied: occupied, game: nil] =
             [3, 2, 9, 1, 6]
             |> Enum.reduce([game, "a"], fn pos, [game, player] ->
               [
                 game
                 |> Keyword.fetch!(:game)
                 |> TicTac.move(player, pos),
                 TicTac.next_player(player, players)
               ]
             end)
             |> hd()

    assert occupied["a"] == [3, 6, 9]
  end

  test "player wins column" do
    players = ["a", "b"]
    game = TicTac.start(players)

    assert [winner: "a", occupied: occupied, game: nil] =
             [7, 1, 6, 2, 5]
             |> Enum.reduce([game, "a"], fn pos, [game, player] ->
               [
                 game
                 |> Keyword.fetch!(:game)
                 |> TicTac.move(player, pos),
                 TicTac.next_player(player, players)
               ]
             end)
             |> hd()

    assert occupied["a"] == [5, 6, 7]
  end
end
