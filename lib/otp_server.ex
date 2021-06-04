defmodule Otp.Actor do
  use GenServer

  @impl true
  def init(initial_number) when is_number(initial_number) do
    # return {:ok, initial_state}
    {:ok, initial_number}
  end

  def init(_initial), do: {:error, "Error"} end

  # :next_number: Client request
  # _from : Client PID
  # current_state: Current State
  @impl true
  def handle_call(:next_number, _from, current_state) do
    next_state = current_state + 1
    response = next_state
    # action:
    #  :reply -> reply to client
    # {action, client response, new state}
    # return {:reply, response, updated_state}
    {:reply, response, next_state}
  end

  @impl true
  def handle_cast({:update_number, number}, _current_state) do
    # return {:noreply, updated_state}
    {:noreply, number}
  end
end

defmodule Otp.Client do
  @actor Otp.Actor

  def run do
    # case GenServer.start_link(Otp.Sequence.Server, 100) do
    case GenServer.start_link(Otp.Actor, 100, name: @actor) do
      {:ok, _pid} ->
        GenServer.call(@actor, :next_number)
        GenServer.call(@actor, :next_number)
        GenServer.call(@actor, :next_number)
        response = GenServer.call(@actor, :next_number)
        IO.puts("[Response: #{response}]")
        GenServer.cast(@actor, {:update_number, 22})
        response = GenServer.call(@actor, :next_number)
        IO.puts("[Response: #{response}]")
        :sys.get_status(@actor)

      {:error, _reason} ->
        IO.puts("Error")
    end
  end
end
