defmodule ElixirAnki.SolBenchmarks do
  alias ElixirAnki.RandMod

  @filename Path.expand("priv/benchmarks/010.txt")
  @file_stream_opts [read_ahead: 100_000]
  @new_line "\n"

  @doc "charlist_"
  def charlist_ do
    @filename
    |> File.read!()
    |> String.split(@new_line)
    |> Enum.map(fn s ->
      s
      |> String.trim()
      |> RandMod.alternating_charlist()
    end)
  end

  @doc "binary_"
  def binary_ do
    @filename
    |> File.read!()
    |> String.split(@new_line)
    |> Enum.map(fn s ->
      s
      |> String.trim()
      |> RandMod.alternating_binary()
    end)
  end

  @doc "charlist_stream"
  def charlist_stream do
    @filename
    |> File.stream!(@file_stream_opts)
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> RandMod.alternating_charlist()
    end)
    |> Enum.to_list()
  end

  @doc "binary_stream"
  def binary_stream do
    @filename
    |> File.stream!(@file_stream_opts)
    |> Stream.map(fn s ->
      s
      |> String.trim()
      |> RandMod.alternating_binary()
    end)
    |> Enum.to_list()
  end

  @doc "binary_flow"
  def binary_flow do
    @filename
    |> File.stream!(@file_stream_opts)
    |> Flow.from_enumerable(max_demand: 200)
    |> Flow.partition(stages: 10)
    |> Flow.map(fn s ->
      s
      |> String.trim()
      |> RandMod.alternating_binary()
    end)
    |> Enum.to_list()
  end

  @doc "charlist_flow"
  def charlist_flow do
    @filename
    |> File.stream!(@file_stream_opts)
    |> Flow.from_enumerable(max_demand: 200)
    |> Flow.map(fn s ->
      s
      |> String.trim()
      |> RandMod.alternating_charlist()
    end)
    |> Enum.to_list()
  end
end
