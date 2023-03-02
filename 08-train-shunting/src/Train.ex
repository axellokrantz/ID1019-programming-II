defmodule Train do

  def take(_, 0) do [] end
  def take([h | tail], n) do
    [h | take(tail, n-1)]
  end

  def drop(rest, 0) do rest end
  def drop([_ | tail], n) do
    drop(tail, n-1)
  end

  def append(train1, train2) do
    train1 ++ train2
  end

  def member([y | _], y) do true end
  def member([], _) do false end
  def member([_ | tail], y) do
    member(tail, y)
  end

  def position([y| _], y, acc) do acc end
  def position([], _, _) do false end
  def position([_ | tail], y, acc) do
    position(tail, y, acc + 1)
  end
  def position(train, y) do
    position(train, y, 1)
  end

  def split([], _, _) do false end
  def split([y|tail], y, train1) do
    {Enum.reverse(train1), tail}
  end
  def split([h|tail], y, train1) do
      split(tail, y, [h | train1])
  end
  def split(train, y) do
    split(train, y, [])
  end

  # k = if you specified that you wanted to move 8 wagons (n)
  # but you only moved 4 wagons. k will equal = 4. (the remaining moves).

  def main([_|tail], n, acc, remain, take) do
    main(tail, n-1, acc + 1, remain, take)
  end
  def main([], _, acc, _, _) do acc end
  def main(train, n) do
    acc = main(train, n, 0, [], [])
    if acc-n < 0 do
      {-(acc - n), [], train}
    else
    {0, take(train, acc-n), drop(train, acc-n)}
    end
  end

  def single(move, tracks) do

      main = elem(tracks, 0)
      track1 = elem(tracks, 1)
      track2 = elem(tracks, 2)

    case move do
      {:one, n} ->
        if n > 0 do
          moved_wagons = main(main, n)
          remain = elem(moved_wagons, 1)
          take = elem(moved_wagons, 2)
          {remain, append(take, track1), track2}
        else
          remain = drop(track1, -n)
          take = take(track1, -n)
          {append(main, take), remain, track2}
        end
      {:two, n} ->
        if n > 0 do
          moved_wagons = main(main, n)
          remain = elem(moved_wagons, 1)
          take = elem(moved_wagons, 2)
          {remain, track1, append(take, track2)}
        else
          remain = drop(track2, -n)
          take = take(track2, -n)
          {append(main, take), track1, remain}
        end
        {_, 0} -> tracks
    end
  end

  def sequence([], _) do [] end
  def sequence([h|tail], tracks) do
    move = single(h, tracks)
    [move | sequence(tail, move)]
  end


end
