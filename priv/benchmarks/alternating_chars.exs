defmodule Benchmark do
  def benchmark do
    alias ElixirAnki.SolBenchmarks

    Benchee.run(%{
      "charlist" => fn -> SolBenchmarks.charlist_() end,
      "binary" => fn -> SolBenchmarks.binary_() end,
      "charlist stream" => fn -> SolBenchmarks.charlist_stream() end,
      "binary stream" => fn -> SolBenchmarks.binary_stream() end,
      "binary flow" => fn -> SolBenchmarks.binary_flow() end,
      "charlist flow" => fn -> SolBenchmarks.charlist_flow() end
    })
  end
end
