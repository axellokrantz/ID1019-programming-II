defmodule Chopstick do
  def start do
    stick = spawn_link(fn -> available() end)
  end

  def available() do
    receive do
      {:request, from} ->
        send(from, {:granted, self()})
        gone()
      :quit -> Process.exit(self(), :kill)
    end
  end

  def gone() do
    receive do
      :return -> available()
      :quit -> Process.exit(self(), :kill)
    end
  end

  def request(left, right, timeout) do
    send(left, {:request, self()})
    send(right, {:request, self()})
    receive do
      {:granted, stick} -> IO.puts("1st chopstick taken"); granted(stick, timeout)
    after
      timeout -> :timeout
    end
  end

  def request(stick, timeout) do
    send(stick, {:request, self()})
    receive do
      {:granted, _} -> :ok
    after
      timeout -> :timeout
    end
  end

  def granted(stick, timeout) do
    receive do
      {:granted, _} -> IO.puts("2nd chopstick taken"); :ok
    after
      timeout ->
        return(stick)
        :timeout
    end
  end

  def return(stick) do send(stick, :return) end

  def quit(stick) do send(stick, :quit) end
end
