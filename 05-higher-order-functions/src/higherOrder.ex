defmodule HigherOrder do

  #def double([]) do [] end
  #def double([h|tail]) do [h * 2 | double(tail)] end

  #def five([]) do [] end
  #def five([h|tail]) do [h + 5 | five(tail)] end

  #def animal([]) do [] end
  #def animal([h|tail]) do [if h == :dog do h = :fido else h end | animal(tail)] end

  def double_five_animal([], _) do [] end
  def double_five_animal([h|tail], type) do
    case type do
      :double -> [h * 2 | double_five_animal(tail, type)]
      :five -> [h + 5 | double_five_animal(tail, type)]
      :animal -> [if h == :dog do h = :fido else do h end | double_five_animal(tail, type)]
    end
  end

  def apply_to_all([], _) do [] end
  def apply_to_all([h|tail], f) do [f.(h)|apply_to_all([tail], f)] end

  def sum([]) do 0 end
  def sum([h|tail]) do h + sum(tail) end

  def fold_right([], acc, _) do acc end
  def fold_right([h|tail], acc, f) do f.(h, fold_right(tail, acc, f))

  def fold_left([], acc, _) do acc end
  def fold_left([h|tail], acc, f) do fold_left(tail, f.(h, acc), f)


  def odd([]) do [] end
  def odd([h|tail]) do
    if rem(h, 2) == 1 do
      [h|odd(tail)]
    else do
      odd(tail)
    end
  end

  def filter([], _) do [] end
  def filter([h|tail], f) do
    if filter.(h, f) do
       [h|filter(tail, f)]
    else do
    filter(tail, f)
    end
  end
