defmodule EnvList do

  def new() do [] end

  def add([], key, value) do [{key, value}] end
  def add([{key, _}|t], key, value) do [{key, value}|t] end
  def add([h|t], key, value) do [h|add(t, key, value)] end

  def lookup([], _) do nil end
  def lookup([{key, value}| _], key) do {key, value} end
  def lookup([_|t], key) do lookup(t, key) end

  def remove([], _) do [] end
  def remove([{key, _}|t], key) do t end
  def remove([h|t], key) do [h|remove(t, key)] end

end
