defmodule Stack.Actor do
  use GenServer, restart: :transient
  require Logger

  @name __MODULE__
  def name, do: @name

  def start_link(stack \\ [], options \\ [name: @name])
      when is_list(stack) and is_list(options) do
    GenServer.start_link(__MODULE__, stack, options)
  end

  def child_spec(stack \\ []) when is_list(stack) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [stack, [name: Stack.Actor.name()]]},
      restart: :transient
    }
  end

  ## Callbacks
  @impl true
  def init(stack) do
    Logger.info("Init...")
    {:ok, stack}
  end

  @impl true
  def handle_call(:pop, _from, [head | tail]) do
    Logger.info("Pop...")
    {:reply, head, tail}
  end

  @impl true
  def handle_call(:pop, _from, [] = state) do
    Logger.info("Pop...")
    {:reply, nil, state}
  end

  @impl true
  def handle_call(:stack, _from, stack) do
    Logger.info("Stack...")
    {:reply, stack, stack}
  end

  @impl true
  def handle_cast({:push, element}, state) do
    Logger.info("Push...")
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
  require Logger

  def run do
    # Supervisor.start_link([Stack.Actor.name()], strategy: :one_for_all)
    children = [
      # {Actor Module, initial state},
      {Stack.Actor, [1]}
      # %{
      # id: identificar la especificación del child
      # id: Stack.Actor,
      # start: módulo-function-args que se invocará para iniciar el proceso hijo
      # Stack.Actor.start_link([1], [name: Stack.Actor.name()])
      # start: {Stack.Actor, :start_link, [[1], [name: Stack.Actor.name()]]}
      # }
    ]

    options = [
      strategy: :one_for_one,
      name: Stack.Supervisor
    ]

    {:ok, _pid} =
      Supervisor.start_link(
        children,
        options
      )

    Stack.Impl.push(2)
    Stack.Impl.push(3)
    Stack.Impl.push(4)
    Stack.Impl.pop()
    Stack.Impl.pop()
    state = Stack.Impl.stack()
    Logger.info("#{inspect(state)}")
    Stack.Impl.pop()
    response = Stack.Impl.pop()
    Logger.info(response)
  end
end
