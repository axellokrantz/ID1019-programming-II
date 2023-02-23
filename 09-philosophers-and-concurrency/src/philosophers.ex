defmodule Philosopher do
  def sleep(0) do :ok end
  def sleep(t) do
    :timer.sleep(:rand.uniform(t))
  end

  def start(hunger, right, left, name, ctrl, timeout, waiter, pos, backoff, seed) do
    spawn_link(fn() -> init(hunger, right, left, name, ctrl, timeout, waiter, pos, backoff, seed) end)
  end

  def init(hunger, right, left, name, ctrl, timeout, waiter, pos, backoff, seed) do
    :rand.seed(:exsss, {seed, seed+1, seed+2})
    dream(hunger, right, left, name, ctrl, timeout, waiter, pos, backoff)
  end

  def waiter() do
    spawn_link(fn() -> take_orders() end)
  end

  def take_orders() do
    IO.puts("Waiter is taking orders")
    receive do
      {:order, from, pos} ->
        send(from, :order_taken)
        take_second_order(pos)
    end
  end

  def take_second_order(occupied) do
    IO.puts("Waiter is taking second order")
    receive do
      {:return, _} -> take_orders()
      {:order, from, pos} ->
        {phil1, phil2} = non_adjacent(occupied)
        if pos == phil1 or pos == phil2 do
          send(from, :order_taken)
          waiter_unavailable(occupied, pos)
        else
          send(from, :unavailable)
          take_second_order(occupied)
        end
    end
  end

  def waiter_unavailable(occupied1, occupied2) do
    IO.puts("Waiter is unavailable")
    receive do
      {:return, pos} ->
        if occupied1 == pos do
          take_second_order(occupied2)
        else
          take_second_order(occupied1)
        end
      {:order, from, _} ->
        send(from, :unavailable)
        waiter_unavailable(occupied1, occupied2)
    end
  end

  def non_adjacent(pos) do
    {rem((pos + 2), 5), rem((pos + 3), 5)}
  end

  def make_order(waiter, pos) do
    send(waiter, {:order, self(), pos})
    receive do
      :order_taken -> :ok
      :unavailable -> :no
    end
  end

  def return_chopsticks(waiter, pos) do
    send(waiter, {:return, pos})
    IO.puts("Waiter was given chopsticks to wash")
  end

  def dream(0, _, _, name, _, _, _, _, _) do
    IO.puts("#{name} starved to death!")
    Process.exit(self(), :kill)
  end
  def dream(hunger, right, left, name, ctrl, timeout, waiter, pos, backoff) do
    send(ctrl, :done)
    sleep(800 + backoff)

    case make_order(waiter, pos) do # with waiter
      :ok -> # with waiter
        case Chopstick.request(left, right, timeout) do
          :ok ->
            IO.puts("#{name} received both chopsticks")
            sleep(800)
            eat(hunger, right, left, name, ctrl, timeout, waiter, pos, backoff + 1600)
          :timeout ->
            IO.puts("Timeout for #{name}! #{hunger} hunger left")
            send(ctrl, :timeout)
            dream(hunger - 1, right, left, name, ctrl, timeout, waiter, pos, backoff + 1600)
        end
      :no ->
        send(ctrl, :timeout)
        dream(hunger - 1, right, left, name, ctrl, timeout, waiter, pos, backoff) # with waiter
    end # with waiter

  #   case Chopstick.request(left, timeout) do
  #     :ok ->
  #       IO.puts("#{name} received left chopstick")
  #       case Chopstick.request(right, timeout) do
  #         :ok ->
  #           IO.puts("#{name} received both chopsticks")
  #           eat(hunger, right, left, name, ctrl, timeout, waiter, pos, backoff)
  #         :timeout ->
  #           IO.puts("Timeout for #{name}!")
  #           IO.puts("#{name} has #{hunger} hunger left")
  #           send(ctrl, :timeout)
  #           dream(hunger - 1, right, left, name, ctrl, timeout, waiter, pos, backoff)
  #       end
  #     :timeout ->
  #       IO.puts("Timeout for #{name}!");
  #       IO.puts("#{name} has #{hunger} hunger left")
  #       send(ctrl, :timeout)
  #       dream(hunger - 1, right, left, name, ctrl, timeout, waiter, pos, backoff)
  #   end
  #   dream(hunger - 1, right, left, name, ctrl, timeout, waiter, pos, backoff)
  end

  def eat(hunger, right, left, name, ctrl, timeout, waiter, pos, backoff) do
    send(ctrl, :eat)
    IO.puts("#{name} is eating")
    Chopstick.return(left)
    Chopstick.return(right)
    return_chopsticks(waiter, pos) # with waiter
    dream(hunger + 1, right, left, name, ctrl, timeout, waiter, pos, backoff)
  end
end
