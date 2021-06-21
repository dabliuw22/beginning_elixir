defmodule Greeter do
  require Logger
  use GenServer

  @registry :greeter_registry

  defp via(name),
    do: {:via, Registry, {@registry, "greeter_for_#{name}"}}

  def start_link(name) do
    GenServer.start_link(__MODULE__, name, name: via(name))
  end

  def child_spec(name) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [name]},
      restart: :transient
    }
  end

  def run({:call, names}) when is_list(names) do
    Logger.info("Run Call #{inspect(names)}")

    names
    |> Enum.map(fn name -> {name, via(name)} end)
    |> Enum.each(fn {name, via} -> GenServer.call(via, name) end)
  end

  def run({:cast, name}) when is_binary(name) do
    Logger.info("Run Cast #{name}")
    name |> via() |> GenServer.cast(name)
  end

  def stop(name) do
    Logger.info("Stop #{name}")
    name |> via() |> Supervisor.stop("Reason")
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_call(name, _from, state) do
    Logger.info("Hello #{name}")
    {:reply, :end, state}
  end

  @impl true
  def handle_cast(name, state) do
    Logger.info("Hello #{name}")
    # GenServer.cast(Greeter.Service.name(), {:end, name})
    {:noreply, state}
  end
end

defmodule Greeter.Service do
  require Logger
  use GenServer

  def name(), do: __MODULE__

  def start_link(_arg) do
    GenServer.start_link(__MODULE__, [], name: name())
  end

  def child_spec(_arg) do
    %{
      id: __MODULE__,
      start: {__MODULE__, :start_link, [[]]},
      restart: :transient
    }
  end

  @impl true
  def init(_) do
    {:ok, nil}
  end

  @impl true
  def handle_call({:greeter, names}, _from, state) when is_list(names) do
    names
    |> Enum.map(fn name -> {name, Greeter.Sup.make_greeter(name)} end)
    |> Enum.map(fn {name, _} -> {name, Greeter.run({:call, name})} end)

    {:reply, nil, state}
  end

  @impl true
  def handle_cast(:greeter, state) do
    limit = :rand.uniform(10)

    Logger.info("Cast")

    gen_list(limit)
    |> Enum.map(fn name -> {name, Greeter.Sup.make_greeter(name)} end)
    |> Enum.map(fn {name, {:ok, _pid}} -> {name, Greeter.run({:cast, name})} end)

    {:noreply, state}
  end

  @impl true
  def handle_cast({:end, name}, state) do
    Process.sleep(10000)
    Greeter.stop(name)
    {:noreply, state}
  end

  defp gen_list(n) do
    for item <- 1..n do
      "Name#{item}"
    end
  end
end

defmodule Greeter.Sup do
  use DynamicSupervisor

  def name(), do: __MODULE__

  def start_link(init_arg) do
    DynamicSupervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  def make_greeter(name) do
    child_spec = {Greeter, name}
    DynamicSupervisor.start_child(__MODULE__, child_spec)
  end
end

defmodule Greeter.App do
  require Logger

  def run do
    children = [
      {Greeter.Service, []},
      {Greeter.Sup, [strategy: :one_for_one, name: Greeter.Sup.name()]},
      {Registry, [keys: :unique, name: :greeter_registry]}
    ]

    opts = [strategy: :one_for_one, name: __MODULE__]
    {:ok, pid} = Supervisor.start_link(children, opts)
    Logger.info("PID #{inspect(pid)}")
    # names = ["Name1", "Name2"]
    # GenServer.call(Greeter.Service, {:greeter, names})
    GenServer.cast(Greeter.Service, :greeter)
  end
end
