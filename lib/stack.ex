defmodule Stack.Actor do
  use GenServer, restart: :transient

  @name __MODULE__
  def name, do: @name

  def start_link(stack \\ []) when is_list(stack) do
    GenServer.start_link(__MODULE__, stack, name: @name)
  end

  @impl true
  def init(stack) do
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    {:reply, head, tail}
  end

  @impl true
  def handle_call(:pop, _from, [] = state) do
    {:reply, nil, state}
  end

  @impl true
  def handle_call(:stack, _from, stack) do
    {:reply, stack, stack}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    {:noreply, [element | state]}
  end
end

defmodule Stack.Impl do
  def pop do
    GenServer.call(Stack.Actor.name(), :pop)
  end

  def stack() do
    GenServer.call(Stack.Actor.name(), :stack)
  end

  def push(element) do
    GenServer.cast(Stack.Actor.name(), {:push, element})
  end
end

defmodule Stack.Client do
  def run do
    # Supervisor.start_link([Stack.Actor.name()], strategy: :one_for_all)
    children = [
      # {Actor Module, initial state}
      {Stack.Actor.name(), []}
    ]

    Supervisor.start_link(
      children,
      strategy: :one_for_one,
      name: Stack.Supervisor
    )

    Stack.Impl.push(2)
    Stack.Impl.push(3)
    Stack.Impl.push(4)
    Stack.Impl.pop()
    Stack.Impl.pop()
    state = Stack.Impl.stack()
    IO.inspect(state)
    Stack.Impl.pop()
    response = Stack.Impl.pop()
    IO.puts(response)
  end
end
