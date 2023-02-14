defmodule D01 do

  def read_file() do
    rawFile = File.read!("inputs/d01")
    processedFile = String.split(rawFile,"\n")
    #Enum.max(create_list(processedFile, 0, []))
    list = create_list(processedFile, 0, [])
    Enum.reduce(top_three(list, 0, 0, 0), fn(x, acc) -> acc + x end)
  end

  def create_list([], acc, lst) do [acc | lst] end
  def create_list([h | t], acc, lst) do
    case h do
      "" -> [acc | create_list(t, 0, lst)]
      _  ->
      {h, _} = Integer.parse(h)
      create_list(t, acc + h, lst)
    end
  end

  def top_three([], f, s, t) do [f, s, t] end
  def top_three([h|tail], f, s, t) do
    cond do
      h > f ->
        top_three(tail, h, f, s)
      h > s ->
        top_three(tail, f, h, s)
      h > t ->
        top_three(tail, f, s, h)
      true ->
        top_three(tail, f, s, t)
    end
  end


end
