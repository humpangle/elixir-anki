defmodule ElixirAnki.ParseEmail do
  @ascii_code_points Enum.concat(?a..?z, ?A..?Z)
  @number_code_points '0123456789'
  @under_score_code_point ?_
  @dash_code_point ?-
  @dot_code_point ?.
  @at_code_point ?@

  @just_before_at Enum.concat([
                    @number_code_points,
                    @ascii_code_points,
                    [
                      @dash_code_point,
                      @under_score_code_point
                    ]
                  ])

  @before_at Enum.concat([
               @number_code_points,
               @ascii_code_points,
               [
                 @dash_code_point,
                 @under_score_code_point,
                 @dot_code_point
               ]
             ])

  @before_dot Enum.concat([
                @number_code_points,
                @ascii_code_points,
                [
                  @dash_code_point,
                  @dot_code_point
                ]
              ])

  @after_dot @ascii_code_points

  @just_before_dot Enum.concat([
                     @ascii_code_points,
                     @number_code_points,
                     [
                       @dash_code_point,
                       @under_score_code_point
                     ]
                   ])

  defstruct before_at: [],
            at: [],
            before_dot: [],
            dot: [],
            after_dot: []

  def parse(""), do: nil

  def parse(email) when is_binary(email) do
    initial_state = %__MODULE__{
      before_at: [],
      at: [],
      before_dot: [],
      dot: [],
      after_dot: []
    }

    email
    |> :binary.bin_to_list()
    |> do_parse({:before_at, initial_state})
  end

  # terminate loop
  defp do_parse(
         [],
         {_next_state,
          %__MODULE__{
            before_at: [_ | _],
            at: [@at_code_point],
            before_dot: [_ | _],
            dot: [@dot_code_point],
            after_dot: [_, _ | _]
          } = state}
       ) do
    {:ok, render(state)}
  end

  # terminate loop
  defp do_parse([], _) do
    {:error, :no_match}
  end

  # begins with a dot
  defp do_parse(
         [@dot_code_point | rest],
         {transform, %{before_at: []} = state}
       ) do
    {:error,
     {
       {transform, "beginning-dot-fail"},
       <<@dot_code_point>>,
       rest,
       render(state)
     }}
  end

  # no 2 consecutive dots
  defp do_parse(
         [@dot_code_point, @dot_code_point | rest],
         {transform, state}
       ) do
    {:error,
     {
       {transform, "consecutive-dots-fail"},
       {<<@dot_code_point>>, <<@dot_code_point>>},
       rest,
       render(state)
     }}
  end

  # before_at -> before_at
  defp do_parse(
         [curr | rest],
         {:before_at,
          %__MODULE__{
            at: [],
            before_dot: [],
            dot: [],
            after_dot: []
          } = state}
       )
       when curr in @before_at and length(rest) > 0 do
    next_state = %{
      state
      | before_at: [curr | state.before_at]
    }

    do_parse(
      rest,
      {:before_at, next_state}
    )
  end

  # before_at -> at
  defp do_parse(
         [@at_code_point | rest],
         {:before_at,
          %__MODULE__{
            before_at: [just_before_at | _],
            at: [],
            before_dot: [],
            dot: [],
            after_dot: []
          } = state}
       )
       when just_before_at in @just_before_at and length(rest) > 0 do
    next_state = %{
      state
      | at: [@at_code_point]
    }

    do_parse(
      rest,
      {:at, next_state}
    )
  end

  # at -> at/dot/_
  defp do_parse(
         [curr | rest],
         {:at, state}
       )
       when curr in [@dot_code_point, @at_code_point, @under_score_code_point] do
    {:error, {{:at, "after-at-fail"}, <<curr>>, rest, render(state)}}
  end

  # at -> before_dot
  # before_dot -> before_dot
  # before_dot -> dot
  defp do_parse(
         [curr | rest],
         {transform,
          %__MODULE__{
            before_at: [_ | _],
            at: [@at_code_point],
            before_dot: bfd,
            dot: [],
            after_dot: []
          } = state}
       )
       when curr in @before_dot and length(rest) > 0 do
    next_state = %{
      state
      | before_dot: [curr | bfd]
    }

    {next_transform, next_state_1, next_rest} =
      case Enum.filter(rest, &(&1 == @dot_code_point)) |> length() do
        0 ->
          {nil, nil, nil}

        1 ->
          case rest do
            # if @dot_code_point is next char
            [@dot_code_point | []] ->
              {nil, nil, nil}

            [@dot_code_point | _] when curr == @dot_code_point ->
              {nil, nil, nil}

            [@dot_code_point | _] when curr not in @just_before_dot ->
              {nil, nil, nil}

            [@dot_code_point | rest_1] when curr in @just_before_dot ->
              {:dot, %{next_state | dot: [@dot_code_point]}, rest_1}

            _ ->
              {:before_dot, next_state, rest}
          end

        _ ->
          {:before_dot, next_state, rest}
      end

    case next_transform do
      nil ->
        {:error,
         {
           {transform, "before dot/dot parsing fail"},
           <<curr>>,
           if(
             next_state_1 == nil,
             do: rest,
             else: next_rest
           ),
           if(
             next_state_1 == nil,
             do: render(next_state),
             else: render(next_state_1)
           )
         }}

      _ ->
        do_parse(next_rest, {next_transform, next_state_1})
    end
  end

  # dot -> end
  # dot -> after_dot
  # after_dot -> after_dot
  # after_dot -> end
  defp do_parse(
         [curr | rest],
         {_transform,
          %__MODULE__{
            before_at: [_ | _],
            at: [@at_code_point],
            before_dot: [_ | _],
            dot: [@dot_code_point],
            after_dot: afd
          } = state}
       )
       when curr in @after_dot do
    next_state = %{
      state
      | after_dot: [curr | afd]
    }

    do_parse(
      rest,
      {:after_dot, next_state}
    )
  end

  defp do_parse([curr | rest], {transform, state}) do
    {:error, {{transform, :unmatched}, <<curr>>, rest, render(state)}}
  end

  defp render(%__MODULE__{} = state) do
    [
      state.before_at,
      state.at,
      state.before_dot,
      state.dot,
      state.after_dot
    ]
    |> Enum.flat_map(&Enum.reverse/1)
    |> Enum.map(&<<&1>>)
    |> Enum.join()
  end
end
