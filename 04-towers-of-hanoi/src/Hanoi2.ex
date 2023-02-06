defmodule Hanoi2 do

  # Send from first to last
  def hanoi(1, from, _, to) do [{:move, from, to}] end
  def hanoi(n, from, aux, to) do
    # Going "left" switch place with aux and to
    # Going "right" switch place with aux and from
    # Middle "node" always goes from first to last
    hanoi(n-1, from, to, aux) ++ [{:move, from, to}] ++ hanoi(n-1, aux, from, to)
  end

end
