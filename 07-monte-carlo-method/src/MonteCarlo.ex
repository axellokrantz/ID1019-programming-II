defmodule MonteCarlo do

  def dart(r) do
    x = Enum.random(0..r)
    y = Enum.random(0..r)
    # Is it a hit or not? Returns true if hit, returns false if miss.
    :math.pow(r, 2) > :math.pow(x, 2) + :math.pow(y, 2)
  end

  def round(0, _, acc) do acc end
  def round(k, r, acc) do
    if dart(r) do
      round(k - 1, r, acc + 1)
    else
      round(k - 1, r, acc)
    end
  end

  # k = number of rounds.
  # j = total darts for one round.
  # t = acc for total darts of all rounds.
  # r = radius.
  # a = acc number of hits for one round.

  # call function rounds(100, 1000, 5)

  def rounds(k, j, r) do
    # start, where t = 0, and a = 0.
    rounds(k, j, 0, r, 0)
  end
  def rounds(0, _, t, _, a) do 4*(a/t) end
  def rounds(k, j, t, r, a) do
    # a grows recursively.
    a = round(j, r, a)
    t = t + j
    pi = 4*(a/t)
    :io.format("Estimate: ~w  Difference: ~w \n", [pi, (pi - :math.pi())])
    rounds(k-1, j*2, t, r, a)
  end

  def leibniz() do
    4 * Enum.reduce(0..10000000, 0, fn(k,a) -> a + 1/(4 * k + 1) - 1/(4 * k + 3) end)
  end

end
