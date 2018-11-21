require Integer

prefix = "Printing: "
suffix = ". Done!"
list = 1..10_000

Benchee.run(%{
  "concatenation" => fn ->
    Enum.each(list, &IO.puts([prefix, "'#{&1}'", suffix]))
  end,
  "inspect" => fn ->
    Enum.each(list, &IO.puts([prefix, "'", inspect(&1), "'", suffix]))
  end,
  "integer_to_string" => fn ->
    Enum.each(list, &IO.puts([prefix, "'", Integer.to_string(&1), "'", suffix]))
  end
})
