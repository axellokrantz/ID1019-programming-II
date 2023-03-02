defmodule Shunt do

  def find([], []) do [] end
  def find(xs, [y| ys]) do
    {hs, ts} = Train.split(xs, y)

    tn = Enum.reduce([y|ts], 0, fn(_, acc) -> acc + 1 end)
    hn = Enum.reduce(hs, 0, fn(_, acc) -> acc + 1 end)

    [{:one, tn}, {:two, hn}, {:one, -tn}, {:two, -hn} | find(Train.append(ts, hs), ys)]
  end

  def few([], []) do [] end
  def few([y | xs], [y | ys]) do few(xs, ys) end
  def few(xs, [y| ys]) do
    {hs, ts} = Train.split(xs, y)

    tn = Enum.reduce([y|ts], 0, fn(_, acc) -> acc + 1 end)
    hn = Enum.reduce(hs, 0, fn(_, acc) -> acc + 1 end)

    [{:one, tn}, {:two, hn}, {:one, -tn}, {:two, -hn} | few(Train.append(hs, ts), ys)]
  end

  # first itteration removes {:one, 1}{:one, -1}
  # second itteration removes {:two, 1}{:one, -1}
  # check pdf.

  def compress(train) do
    new_train = rules(train)
      if new_train == train do
      train
      else
      compress(new_train)
    end
  end

  def rules([]) do [] end
  def rules([{:one, 0}|tail]) do rules(tail) end
  def rules([{:two, 0}|tail]) do rules(tail) end
  def rules([{:one, n}, {:one, m}|tail]) do
    rules([{:one, n+m}|tail])
  end
  def rules([{:two, n}, {:two, m}|tail]) do
    rules([{:two, n+m}|tail])
  end
  def rules([move|tail]) do
    [move|rules(tail)]
  end

end
