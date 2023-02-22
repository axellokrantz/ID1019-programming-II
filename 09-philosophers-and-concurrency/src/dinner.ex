defmodule Dinner do
  def start(), do: spawn(fn -> init() end)

  def init() do
    timeout = 1000
    start_time = current_time()
    seed = DateTime.to_unix(DateTime.utc_now())

    ctrl = self()
    waiter = Philosopher.waiter()
    c1 = Chopstick.start()
    c2 = Chopstick.start()
    c3 = Chopstick.start()
    c4 = Chopstick.start()
    c5 = Chopstick.start()
    Philosopher.start(c1, c2, "Arendt", ctrl, timeout, waiter, 1, rem(seed, 82))
    Philosopher.start(c2, c3, "Hypatia", ctrl, timeout, waiter, 2, rem(seed * 2, 51))
    Philosopher.start(c3, c4, "Simone", ctrl, timeout, waiter, 3, rem(seed * 3, 321))
    Philosopher.start(c4, c5, "Elisabeth", ctrl, timeout, waiter, 4, rem(seed * 4, 8912))
    Philosopher.start(c5, c1, "Ayn", ctrl, timeout, waiter, 5, rem(seed * 5, 3152))
    wait(100, 0, [c1, c2, c3, c4, c5], start_time)
  end

  def wait(0, times_eaten, chopsticks, start_time) do
    IO.puts("Execution time: #{execution_time(start_time)}")
    IO.puts("The philosophers ate: #{times_eaten} times")
    Enum.each(chopsticks, fn(c) ->
      Chopstick.quit(c) end)
    Process.exit(self(), :kill)
  end
  def wait(n, times_eaten, chopsticks, start_time) do
    receive do
      :done -> wait(n-1, times_eaten, chopsticks, start_time)
      :abort -> Process.exit(self(), :kill)
      :eat -> wait(n, times_eaten + 1, chopsticks, start_time)
    end
  end

  def current_time() do
    elem(DateTime.now("Etc/UTC"), 1)
  end

  def execution_time(start_time) do
    DateTime.diff(current_time(), start_time, :millisecond)
  end
end
