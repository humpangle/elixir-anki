alias ElixirAnki.Solution
# Solution.start()

filename = Path.expand("priv/benchmarks/alternating_chars.txt")

lines =
  filename
  |> File.read!()
  |> String.split("\n")
  |> Enum.take(2)
  |> IO.inspect(label: "
  -----------label------------
  ")
  |> Enum.map(fn s ->
    s
    |> String.trim()
    |> Solution.make1()
    |> to_string()
  end)

lines
|> inspect()
|> IO.puts()
