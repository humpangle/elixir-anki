defmodule ElixirAnki.Repo do
  use Ecto.Repo, otp_app: :elixir_anki
  use Scrivener, page_size: 10

  @doc """
  Dynamically loads the repository url from the
  DATABASE_URL environment variable.
  """
  def init(_, opts) do
    {:ok, Keyword.put(opts, :url, System.get_env("DATABASE_URL"))}
  end

  def execute_and_load(sql, params \\ []) do
    sql
    |> query!(params)
    |> process_query_result()
  end

  def execute_and_load(sql, params, schema) do
    fields =
      sql
      |> query!(params)
      |> process_query_result()

    Ecto.Schema.__safe_load__(
      schema,
      [],
      [],
      nil,
      fields,
      &Ecto.Type.adapter_load(__adapter__(), &1, &2)
    )
  end

  defp process_query_result(%{command: :delete} = result) do
    result
    |> Map.from_struct()
    |> Map.take([:num_rows, :command])
  end

  defp process_query_result(%{rows: rows, columns: columns}) do
    Enum.map(rows, fn row ->
      columns
      |> Enum.zip(row)
      |> Enum.into(%{})
    end)
  end
end
