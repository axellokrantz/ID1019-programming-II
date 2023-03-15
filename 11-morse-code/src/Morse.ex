defmodule Morse do

  defmodule Node do
    defstruct [:left, :right]
  end

  defmodule Leaf do
    defstruct [:char]
  end

  def traverse(morse \\ morse_tree(), path \\ [], table \\ %{})

  def traverse({:node, val, nil, nil}, path, map) do
    case val do
      :na -> map
      _ -> Map.put(map, List.to_string([val]), path)
    end
  end

  def traverse({:node, val, left, nil}, path, map) do
    case val do
      :na -> traverse(left, insert_last(path, "-"), map)
      _ -> traverse(left, insert_last(path, "-"), Map.put(map, List.to_string([val]),path))
    end
  end

  def traverse({:node, val, nil, right}, path, map) do
    case val do
      :na -> traverse(right, insert_last(path, "."), map)
      _ -> traverse(right, insert_last(path, "."), Map.put(map, List.to_string([val]),path))
    end
  end

  def traverse({:node, :na, left, right}, path, map) do
    map = traverse(left, insert_last(path, "-"), map)
    traverse(right, insert_last(path, "."), map)
  end

  def traverse({:node, val, left, right}, path, map) do
    map = traverse(left, insert_last(path, "-"), Map.put(map, List.to_string([val]), path))
    traverse(right, insert_last(path, "."), map)
  end

  def charlist(text, list \\ [])
  def charlist([], list) do Enum.reverse(list) end
  def charlist([char | text], list) do
    charlist(text, [List.to_string([char]) | list])
  end

  def encode(str) do
    table = codes()
    foldleft(Enum.reverse(str), table, [])
    |> List.to_string()
  end

  def foldleft([], _, final) do final end
  def foldleft([ch | rest], table, sofar) do
    code = Enum.find(table, fn {key, _} -> ch == key end) |> elem(1)
    code = code <> " "
    foldleft(rest, table, [code | sofar])
  end

  def decode(seq \\ sample(), morse_tree \\ morse_tree())
  def decode([], _) do [] end
  def decode(seq, morse_tree) do
    {char, rest} = lookup(seq, morse_tree)
    [char | decode(rest, morse_tree)]
  end

  def lookup([sign | rest], {:node, val, left, right}) do
    case sign do
      46 -> lookup(rest, right)
      45 -> lookup(rest, left)
      32 -> {val, rest}
    end
  end

  def insert_last([h | tail], val) do
    [h | insert_last(tail, val)]
  end

  def insert_last([], val) do [val] end

  def morse_tree() do
    {:node, :na,
      {:node, 116,
        {:node, 109,
          {:node, 111,
            {:node, :na, {:node, 48, nil, nil}, {:node, 57, nil, nil}},
            {:node, :na, nil, {:node, 56, nil, {:node, 58, nil, nil}}}},
          {:node, 103,
            {:node, 113, nil, nil},
            {:node, 122,
              {:node, :na, {:node, 44, nil, nil}, nil},
              {:node, 55, nil, nil}}}},
        {:node, 110,
          {:node, 107, {:node, 121, nil, nil}, {:node, 99, nil, nil}},
          {:node, 100,
            {:node, 120, nil, nil},
            {:node, 98, nil, {:node, 54, {:node, 45, nil, nil}, nil}}}}},
      {:node, 101,
        {:node, 97,
          {:node, 119,
            {:node, 106,
              {:node, 49, {:node, 47, nil, nil}, {:node, 61, nil, nil}},
              nil},
            {:node, 112,
              {:node, :na, {:node, 37, nil, nil}, {:node, 64, nil, nil}},
              nil}},
          {:node, 114,
            {:node, :na, nil, {:node, :na, {:node, 46, nil, nil}, nil}},
            {:node, 108, nil, nil}}},
        {:node, 105,
          {:node, 117,
            {:node, 32,
              {:node, 50, nil, nil},
              {:node, :na, nil, {:node, 63, nil, nil}}},
            {:node, 102, nil, nil}},
          {:node, 115,
            {:node, 118, {:node, 51, nil, nil}, nil},
            {:node, 104, {:node, 52, nil, nil}, {:node, 53, nil, nil}}}}}}
  end

  def sample() do
    '.... - - .--. ... ---... .----- .----- .-- .-- .-- .-.-.- -.-- --- ..- - ..- -... . .-.-.- -.-. --- -- .----- .-- .- - -.-. .... ..--.. ...- .----. -.. .--.-- ..... .---- .-- ....- .-- ----. .--.-- ..... --... --. .--.-- ..... ---.. -.-. .--.-- ..... .---- '
  end

  def codes() do
    [{32,"..--"},
     {37,".--.--"},
     {44,"--..--"},
     {45,"-....-"},
     {46,".-.-.-"},
     {47,".-----"},
     {48,"-----"},
     {49,".----"},
     {50,"..---"},
     {51,"...--"},
     {52,"....-"},
     {53,"....."},
     {54,"-...."},
     {55,"--..."},
     {56,"---.."},
     {57,"----."},
     {58,"---..."},
     {61,".----."},
     {63,"..--.."},
     {64,".--.-."},
     {97,".-"},
     {98,"-..."},
     {99,"-.-."},
     {100,"-.."},
     {101,"."},
     {102,"..-."},
     {103,"--."},
     {104,"...."},
     {105,".."},
     {106,".---"},
     {107,"-.-"},
     {108,".-.."},
     {109,"--"},
     {110,"-."},
     {111,"---"},
     {112,".--."},
     {113,"--.-"},
     {114,".-."},
     {115,"..."},
     {116,"-"},
     {117,"..-"},
     {118,"...-"},
     {119,".--"},
     {120,"-..-"},
     {121,"-.--"},
     {122,"--.."}]
  end
end
