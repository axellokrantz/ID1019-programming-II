defmodule Philosopher do
  def sleep(0) do :ok end
  def sleep(t) do
    :timer.sleep(:rand.uniform(t))
  end

  def start(right, left, name, ctrl, timeout, waiter, pos, seed) do
    spawn_link(fn() -> init(right, left, name, ctrl, timeout, waiter, pos, seed) end)
  end

  def init(right, left, name, ctrl, timeout, waiter, pos, seed) do
    :rand.seed(:exsss, {seed, seed+1, seed+2})
    idle(right, left, name, ctrl, timeout, waiter, pos)
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
      {:wash, _} -> take_orders()
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
      {:wash, pos} ->
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
    phil1 = if (pos + 2) > 5 do
      rem(pos + 2, 6) + 1
    else
      pos + 2
    end

    phil2 = if (pos + 3) > 5 do
      rem(pos + 3, 6) + 1
    else
      pos + 3
    end

    {phil1, phil2}
  end

  # def take_orders() do
  #   IO.puts("Waiter is taking orders")
  #   receive do
  #     {:order, from, _} ->
  #       send(from, :order_taken)
  #       washing_chopsticks()
  #   end
  # end

  # def washing_chopsticks() do
  #   receive do
  #     {:wash, _} -> take_orders()
  #     {:order, from, _} ->
  #       send(from, :unavailable)
  #       washing_chopsticks()
  #   end
  # end

  def make_order(waiter, pos) do
    send(waiter, {:order, self(), pos})
    receive do
      :order_taken -> :ok
      :unavailable -> :no
    end
  end

  def request_wash(waiter, pos) do
    send(waiter, {:wash, pos})
    IO.puts("Waiter was given chopsticks to wash")
  end

  # def idle(0, _, _, name, _, _, _) do
  #   IO.puts("#{name} starved to death!")
  #   Process.exit(self(), :kill)
  # end
  def idle(right, left, name, ctrl, timeout, waiter, pos) do
    send(ctrl, :done)
    sleep(800)

    case make_order(waiter, pos) do # with waiter
      :ok -> # with waiter
        case Chopstick.request(left, right, timeout) do
          :ok ->
            IO.puts("#{name} received both chopsticks")
            eat(right, left, name, ctrl, timeout, waiter, pos)
          :timeout ->
            IO.puts("Timeout for #{name}!")
            idle(right, left, name, ctrl, timeout, waiter, pos)
        end
      :no -> idle(right, left, name, ctrl, timeout, waiter, pos) # with waiter
    end # with waiter

    # case Chopstick.request(left, timeout) do
    #   :ok ->
    #     IO.puts("#{name} received left chopstick")
    #     case Chopstick.request(right, timeout) do
    #       :ok ->
    #         IO.puts("#{name} received both chopsticks")
    #         eat(right, left, name, ctrl, timeout, waiter, pos)
    #       :timeout ->
    #         IO.puts("Timeout for #{name}!")
    #         idle(right, left, name, ctrl, timeout, waiter, pos)
    #     end
    #   :timeout ->
    #     IO.puts("Timeout for #{name}!");
    #     idle(right, left, name, ctrl, timeout, waiter, pos)
    # end
  end

  def eat(right, left, name, ctrl, timeout, waiter, pos) do
    send(ctrl, :eat)
    IO.puts("#{name} is eating")
    sleep(1000)
    Chopstick.return(left)
    IO.puts("#{name} returned left chopstick");
    Chopstick.return(right)
    IO.puts("#{name} returned right chopstick");
    request_wash(waiter, pos) # with waiter
    idle(right, left, name, ctrl, timeout, waiter, pos)
  end
end
