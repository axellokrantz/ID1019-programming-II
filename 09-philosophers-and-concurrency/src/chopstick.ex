defmodule Chopstick do
  def start do
    stick = spawn_link(fn -> available() end)
  end

  def available() do
    receive do
      {:request, from} ->
        send(from, :granted)
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
      :granted -> IO.puts("1st chopstick taken"); granted(timeout)
    after
      timeout -> :timeout
    end
  end

  def request(stick, timeout) do
    send(stick, {:request, self()})
    receive do
      :granted -> :ok
    # after
    #   timeout -> :timeout
    end
  end

  def granted(timeout) do
    receive do
      :granted -> IO.puts("2nd chopstick taken"); :ok
    # after
    #   timeout -> :timeout
    end
  end

  def return(stick) do send(stick, :return) end

  def quit(stick) do send(stick, :quit) end
end
