defmodule ElixirAnki.TaskAsync do
  use GenServer

  @type state :: %{
          data: [Integer.t()],
          computer: (Integer.t() -> Integer.t()),
          timeout: Integer.t() | :infinity,
          reducer: (any, any -> any),
          initial: 0 | any,
          owner: pid
        }

  @name __MODULE__

  @doc """
    User can use make/0 or make/1 or make/2 or make/3 to make initial value of
    the state for the async task.

    #EXAMPLES
      iex> make()
        %{
          data: [1, -10, 250, 500, ...],
          timeout: :infinity,
          computer: fn/1,
          reducer: fn/1,
          initial: 25,
          owner: <1.513.45::pid>
        }
  """
  @spec make(diff :: Integer.t(), timeout :: Integer.t() | :infinity, initial :: 0 | any) :: state
  def make(diff \\ 0, timeout \\ :infinity, initial \\ 0) do
    computer = fn val when val > 0 ->
      me = inspect(self())
      val_ = inspect(val)

      IO.puts(["Process: ", me, " sleeping for: ", val_, " seconds."])

      Process.sleep(val)

      IO.puts(["Process: ", me, " waking up after: ", val_, " seconds."])

      val
    end

    %{
      data: Enum.map(1..10, fn _ -> :rand.uniform(1000) - diff end),
      timeout: timeout,
      computer: computer,
      reducer: &+/2,
      initial: initial,
      owner: self()
    }
  end

  @doc """
    Waits until the aggregate result of the parallel computation is returned.

    If there is a successful run without timeout, then a tuple
    {:result, result}, where 'result' is the result of running the computation
    is returned.

    If there is a successful run but there is timeout, then a tuple
    {:timeout, result}, where 'result' is the result of
    the computation before the timeout was hit, is returned.

    If the computations did not succeed and we have waited after
    timeout, `:noop` is returned.

    #Examples

    iex> await(pid)
      {:result, 1245}

    iex> await(pid, 1_000)
      {:timeout, 1234}

    iex> await(pid)
      :noop
  """
  @spec await(pid :: pid, timeout :: pos_integer) :: {:result, any} | {:timeout, any} | :noop
  def await(pid, timeout \\ 5_000) do
    receive do
      {^pid, response} -> response
    after
      timeout -> :noop
    end
  end

  @doc """
    Starts the GenServer, returning the pid for a successful start.
  """
  @spec start(state :: state) :: pid()
  def start(state) do
    {:ok, pid} = GenServer.start_link(@name, state, name: @name)
    pid
  end

  def init(state) do
    GenServer.cast(@name, {:init, state})
    {:ok, state}
  end

  def handle_cast({:init, %{data: data, computer: computer, timeout: timeout} = state}, _) do
    workers =
      Enum.map(data, fn val ->
        pid =
          spawn(fn ->
            result = computer.(val)
            GenServer.cast(@name, {:result, result, self()})
          end)

        {pid, Process.monitor(pid)}
      end)
      |> Enum.into(%{})

    state =
      state
      |> Map.drop([:data, :computer])
      |> Map.merge(%{
        workers: workers,
        timeout: make_timeout(timeout)
      })

    {:noreply, state}
  end

  def handle_cast(
        {:result, result, pid},
        %{
          initial: initial,
          reducer: reducer,
          workers: workers
        } = state
      ) do
    %{
      state
      | initial: reducer.(initial, result),
        workers: purge_task(pid, workers)
    }
    |> done?()
  end

  def handle_info({:timeout, timeoutref}, %{timeout: timeoutref} = state) do
    done?(%{state | timeout: true})
  end

  def handle_info({:DOWN, _ref, :process, pid, _reason}, %{workers: workers} = state) do
    %{
      state
      | workers: purge_task(pid, workers)
    }
    |> done?()
  end

  defp done?(%{workers: workers, initial: initial} = state) when workers == %{},
    do: do_stop({:result, initial}, state)

  defp done?(%{timeout: true, initial: initial} = state), do: do_stop({:timeout, initial}, state)

  defp done?(state), do: {:noreply, state}

  defp do_stop(result, %{owner: owner, workers: workers} = state) do
    send(owner, {self(), result})

    Enum.map(workers, fn {_, ref} -> Process.demonitor(ref, [:flush]) end)

    {:stop, :normal, state}
  end

  defp purge_task(pid, %{} = workers) when is_pid(pid) do
    case Map.pop(workers, pid) do
      {nil, workers} ->
        workers

      {ref, workers} ->
        Process.demonitor(ref, [:flush])
        workers
    end
  end

  defp make_timeout(:infinity), do: nil

  defp make_timeout(timeout) when is_integer(timeout) do
    timeoutref = make_ref()
    Process.send_after(self(), {:timeout, timeoutref}, timeout)
    timeoutref
  end
end
