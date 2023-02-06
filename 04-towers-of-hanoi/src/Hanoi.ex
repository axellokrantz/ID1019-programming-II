defmodule Hanoi do

  def pm(start, finish) do
    IO.puts("#{start} -> #{finish}")
  end
  def h(n, start, finish) do
    case n do
      1 -> pm(start, finish)
      _ ->
        other = 6 - (start + finish)
        h(n-1, start, other)
        pm(start, finish)
        h(n-1, other, finish)
    end
  end
end
