defmodule ElixirAnki.Algo do
  def primes(2), do: [2]

  def primes(num) when is_integer(num) and num < 2, do: []

  def primes(num) when is_integer(num) do
    primes([2], primes(2, 3..num))
  end

  def primes(acc, []), do: Enum.sort(acc)

  def primes(acc, [next | rest]) do
    acc = [next | acc]
    primes(acc, primes(next, rest))
  end


  

  def primes(num, list) when is_integer(num) do
    list
    |> Enum.reduce([], fn elm, acc ->
      case rem(elm, num) do
        0 -> acc
        _ -> [elm | acc]
      end
    end)
    |> Enum.reverse()
  end

  def balanced_brackets(string) when is_binary(string) do
    balanced_brackets(String.graphemes(string), 0)
  end

  def balanced_brackets([], 0), do: true

  def balanced_brackets(_, acc) when acc < 0, do: false

  def balanced_brackets([], _), do: false

  def balanced_brackets(["(" | tail], acc), do: balanced_brackets(tail, acc + 1)

  def balanced_brackets([")" | tail], acc), do: balanced_brackets(tail, acc - 1)
end
