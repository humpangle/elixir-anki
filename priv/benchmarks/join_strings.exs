string = "123456"
list = 1..10_000

Benchee.run(%{
  "concatenation" => fn ->
    Enum.each(list, &IO.puts("#{&1}: #{string} #{string}"))
  end,
  "join" => fn ->
    Enum.each(list, &IO.puts(Enum.join([&1, ": ", string, " ", string])))
  end
})
