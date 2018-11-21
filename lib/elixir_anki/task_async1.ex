defmodule ElixirAnki.Me do
  use GenServer

  def start_link(%{} = initial) do
    GenServer.start_link(__MODULE__, initial, name: __MODULE__)
  end

  @doc false
  @impl true
  def init(%{} = initial) do
    GenServer.cast(__MODULE__, {:init, initial})
    {:ok, initial}
  end

  @impl true
  def handle_cast({:init, initial}, state) do
    calc = initial.calc

    tasks =
      for datum <- initial.data, into: %{} do
        {:ok, pid} =
          Task.Supervisor.start_child(
            ElixirAnki.TaskSupervisor,
            fn ->
              result = calc.(datum)
              GenServer.cast(__MODULE__, {:result, result, self()})
            end
          )

        ref = Process.monitor(pid)
        {pid, ref}
      end

    state =
      state
      |> Map.merge(%{
        tasks: tasks,
        timeout: false,
        timeout_ref: setup_timeout(initial.timeout),
        result: initial.initial
      })

    {:noreply, state}
  end

  def handle_cast({:result, result, pid}, state),
    do:
      done?(%{
        state
        | tasks: purge_task(pid, state.tasks),
          result: state.aggregator.(state.result, result)
      })

  @impl true
  def handle_info(
        {:timeout, timeout_ref},
        %{timeout_ref: timeout_ref} = state
      ),
      do: done?(%{state | timeout: true})

  def handle_info({:DOWN, _ref, :process, pid, _reason}, state),
    do: done?(%{state | tasks: purge_task(pid, state.tasks)})

  defp done?(%{timeout: true} = state) do
    purge_tasks(state.tasks)
    send(state.owner, {:timeout, state.work_ref, state.result})
    {:stop, :normal, state}
  end

  defp done?(%{tasks: tasks} = state) when tasks == %{} do
    send(state.owner, {:result, state.work_ref, state.result})
    {:stop, :normal, state}
  end

  defp done?(state), do: {:noreply, state}

  defp purge_task(pid, tasks) do
    case Map.pop(tasks, pid) do
      {nil, tasks} ->
        tasks

      {ref, tasks} ->
        Process.demonitor(ref, [:flush])
        tasks
    end
  end

  defp purge_tasks(tasks),
    do:
      Enum.each(tasks, fn {pid, _} ->
        purge_task(pid, tasks)
        Process.exit(pid, :brutal_kill)
      end)

  defp setup_timeout(:infinity), do: nil

  defp setup_timeout(timeout) do
    timeout_ref = make_ref()
    Process.send_after(self(), {:timeout, timeout_ref}, timeout)
    timeout_ref
  end

  defp aggregator(a, b), do: a + b

  defp calc(val) when val >= 0 do
    me = self() |> inspect()
    val_ = to_string(val)
    IO.puts([me, " sleeping for: ", val_, " secs"])
    Process.sleep(val)
    IO.puts([me, " waking up after sleeping for ", val_, " secs"])
    val
  end

  def gen(timeout \\ :infinity, diff \\ 0) do
    %{
      owner: self(),
      work_ref: make_ref(),
      timeout: timeout,
      initial: 0,
      calc: &calc/1,
      aggregator: &aggregator/2,
      data:
        1..10
        |> Enum.map(fn _ -> :rand.uniform(1000) - diff end)
    }
  end

  def bal(string) when is_binary(string) do
    case String.trim(string) do
      "" -> false
      s -> balp(s, [])
    end
  end

  defp balp("", []), do: true
  defp balp("", _list), do: false
  defp balp("}", []), do: false
  defp balp("]", []), do: false
  defp balp(")", []), do: false
  defp balp("{" <> rest, list), do: balp(rest, ["}" | list])
  defp balp("[" <> rest, list), do: balp(rest, ["]" | list])
  defp balp("(" <> rest, list), do: balp(rest, [")" | list])
  defp balp("}" <> rest_str, ["}" | rest_list]), do: balp(rest_str, rest_list)
  defp balp("]" <> rest_str, ["]" | rest_list]), do: balp(rest_str, rest_list)
  defp balp(")" <> rest_str, [")" | rest_list]), do: balp(rest_str, rest_list)
  defp balp("}" <> _rest_str, _list), do: false
  defp balp("]" <> _rest_str, _list), do: false
  defp balp(")" <> _rest_str, _list), do: false
  defp balp(_str, _list), do: false
end
