defmodule ElixirAnki.Lab do
  def make_one(letter, how_many) do
    1..how_many
    |> Enum.map(fn num ->
      "#{String.upcase(letter)}#{num}"
    end)
  end

  def makeall(how_many) do
    makeall("hov", how_many)
  end

  def makeall(letters, how_many) do
    letters
    |> String.graphemes()
    |> Enum.map(&make_one(&1, how_many))
  end

  def permutation([left, center, right]) do
    permutation(left, center, right)
  end

  def permutation(left, center, right) do
    permutation(left, center)
    |> Enum.flat_map(fn left_center ->
      Enum.map(right, fn right_ -> [right_ | left_center] end)
    end)
  end

  def permutation(left, right) when is_list(right) and is_list(left) do
    left
    |> Enum.flat_map(fn left_ ->
      permutation(left_, right)
    end)
  end

  def permutation(left, right) when is_list(right) and not is_list(left) do
    Enum.map(right, fn right_ -> [left, right_] end)
  end

  def join_all(data) do
    data
    |> Enum.map(&Enum.join(&1, ","))
    |> Enum.join("\r\n")
  end

  def write(data) do
    f = File.open!("lab.csv", [:write])
    IO.write(f, data)
    File.close(f)
  end
end
