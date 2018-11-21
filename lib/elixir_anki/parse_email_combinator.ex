defmodule ElixirAnki.ParseEmailCombinator do
  @dot_string "."
  @dot_code_point ?.
  @empty_string ""
  @at_code_point ?@
  @at_string "@"

  @just_before_first_at [
    ?.,
    ?_
  ]

  @just_after_first_at [
    ?.,
    ?_,
    ?@
  ]

  @before_dot [
    ?_,
    ?@,
    ?.
  ]

  @after_dot Enum.concat([?a..?z, ?A..?Z])

  @label_after_dot "after_dot"
  @label_before_dot "before_dot"
  @label_apply_next "apply next"
  @label_must_not_start_with_dot "must_not_start_with_dot"
  @label_before_first_at "before_first_at"
  @label_just_after_first_at "You may not have
  (1) A dot
  (2) An @
  (3) And _
  After @"

  @label_first_at "first_at:
  An @ must not be first string consumed.
  An at must be followed by a char"

  defstruct result: [],
            column: 0,
            label: @empty_string,
            unused: @empty_string,
            consumed: @empty_string

  def parse(email) when is_binary(email) do
    parsers = [
      &must_not_start_with_dot/1,
      &before_first_at/1,
      &first_at/1,
      &just_after_first_at/1,
      &before_dot/1,
      &dot/1,
      &after_dot/1
    ]

    parsers(parsers, %__MODULE__{unused: email})
  end

  def parsers(
        _,
        %__MODULE__{
          unused: <<@dot_string, @dot_string, _rest::binary>>
        } = state
      ) do
    {
      :error,
      %{
        state
        | column: [state.column + 1, state.column + 2],
          label: "Consecutive dots not allowed"
      }
    }
  end

  def parsers(
        _,
        %__MODULE__{
          unused: <<before_at, @at_string, _rest::binary>>
        } = state
      )
      when before_at in @just_before_first_at do
    {
      :error,
      %{
        state
        | column: state.column + 1,
          label: "@ can not be preceded by ./_"
      }
    }
  end

  def parsers([], %__MODULE__{unused: ""} = state) do
    {:ok, state}
  end

  def parsers([], %__MODULE__{} = state) do
    {:error, state}
  end

  # def parsers(_, %__MODULE__{} = state) do
  #   {{:error, :no_match}, state}
  # end

  def parsers([parser | rest] = parsers, %__MODULE__{} = state) do
    case parser.(state) do
      %__MODULE__{label: @label_apply_next} = next_state ->
        parsers(rest, next_state)

      %__MODULE__{} = next_state ->
        parsers(parsers, next_state)

      {:error, %__MODULE__{}} = other ->
        other
    end
  end

  # errors
  defp must_not_start_with_dot(
         %{
           unused: <<@dot_string, rest::binary>>,
           consumed: @empty_string
         } = state
       ) do
    {
      :error,
      %{
        state
        | column: 1,
          label: @label_must_not_start_with_dot,
          unused: rest,
          consumed: @empty_string
      }
    }
  end

  defp must_not_start_with_dot(
         %{
           unused: <<c, rest::binary>>,
           consumed: @empty_string
         } = state
       ) do
    char = <<c>>

    %{
      state
      | column: 1,
        label: @label_apply_next,
        unused: rest,
        consumed: @empty_string,
        result: [state.consumed <> char | state.result]
    }
  end

  defp before_first_at(
         %{
           unused: <<@at_string, _rest::binary>>,
           consumed: consumed
         } = state
       )
       when consumed != @empty_string do
    %{
      state
      | label: @label_apply_next,
        consumed: @empty_string,
        result: [state.consumed | state.result]
    }
  end

  defp before_first_at(
         %{
           unused: <<c, rest::binary>>
         } = state
       )
       when c != @at_code_point do
    char = <<c>>

    %{
      state
      | column: state.column + 1,
        label: @label_before_first_at,
        unused: rest,
        consumed: state.consumed <> char
    }
  end

  defp before_first_at(state) do
    {:error, %{state | column: state.column + 1}}
  end

  defp first_at(
         %{
           unused: <<@at_string, rest::binary>>
         } = state
       ) do
    %{
      state
      | column: state.column + 1,
        label: @label_apply_next,
        consumed: @empty_string,
        unused: rest,
        result: [state.consumed <> @at_string | state.result]
    }
  end

  defp first_at(state) do
    {
      :error,
      %{
        state
        | label: @label_first_at,
          column: state.column + 1
      }
    }
  end

  defp just_after_first_at(
         %{
           unused: <<c, rest::binary>>
         } = state
       )
       when c not in @just_after_first_at do
    char = <<c>>

    %{
      state
      | column: state.column + 1,
        label: @label_apply_next,
        consumed: @empty_string,
        unused: rest,
        result: [state.consumed <> char | state.result]
    }
  end

  defp just_after_first_at(state) do
    {
      :error,
      %{
        state
        | column: state.column + 1,
          label: @label_just_after_first_at
      }
    }
  end

  defp before_dot(
         %{
           unused: <<c, rest::binary>>
         } = state
       )
       when c in @before_dot do
    char = <<c>>

    next_state =
      case rest
           |> String.graphemes()
           |> Enum.filter(&(&1 == @dot_string))
           |> length() do
        0 ->
          %{
            state
            | label: @label_apply_next,
              result: [state.consumed <> char | state.result]
          }

        1 when c == @dot_code_point ->
          %{
            state
            | label: @label_apply_next,
              result: [state.consumed <> char | state.result]
          }

        _ ->
          %{
            state
            | column: state.column + 1,
              unused: rest,
              consumed: @empty_string,
              label: @label_before_dot
          }
      end

    next_state
  end

  defp dot(
         %{
           unused: <<@dot_string, next_char, rest::binary>>
         } = state
       ) do
    %{
      state
      | column: state.column + 1,
        unused: <<next_char, rest::binary>>,
        consumed: @empty_string,
        label: @label_apply_next,
        result: [state.consumed <> @dot_string | state.result]
    }
  end

  defp dot(state) do
    {:error, %{state | column: state.column + 1}}
  end

  defp after_dot(
         %{
           unused: @empty_string
         } = state
       ) do
    %{
      state
      | label: @label_apply_next,
        consumed: @empty_string,
        result: [state.consumed | state.result]
    }
  end

  defp after_dot(
         %{
           unused: <<c, rest::binary>>
         } = state
       )
       when c in @after_dot do
    %{
      state
      | column: state.column + 1,
        unused: rest,
        consumed: state.consumed <> <<c>>,
        label: @label_after_dot
    }
  end

  defp after_dot(state) do
    {:error, %{state | column: state.column + 1}}
  end
end
