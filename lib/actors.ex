defmodule Actor do
  def handle do
    receive do
      {:greeting, name} ->
        IO.puts("Hello #{name}")
    end

    handle()
  end
end

defmodule Client do
  def run do
    pid = spawn(Actor, :handle, [])
    send(pid, {:greeting, "Name"})
  end
end
