defmodule Huffman do

  defmodule Node do
    defstruct [:left, :right]
  end

  defmodule Leaf do
    defstruct [:key]
  end

  def sample do
    'the quick brown fox jumps over the lazy dog
    this is a sample text that we will use when we build
    up a table we will only handle lower case letters and
    no punctuation symbols the frequency will of course not
    represent english but it is probably not that far off'
  end

  def text() do
    'this is something that we should encode'
  end

  def read(file) do
    {:ok, file} = File.open(file, [:read, :utf8])
    binary = IO.read(file, :all)
    File.close(file)
    case :unicode.characters_to_list(binary, :utf8) do
    {:incomplete, list, _} ->
        list
      list ->
        list
    end
  end

  # graphemes = split string into separate characters.
  # Map.update = 1 is the default value, will be used for all entries first time.
  # map = where all entries are stored.
  # char = character
  # val = value of key: char

  # Sorted by frequency.

  #converts all our characters to leafs with corresponding frequencies.

  def freq(text \\ 'gurka')
  def freq(text) do
    freq =
      text
      |> to_atom_list
      |> Enum.reduce(%{}, fn char, map ->
        Map.update(map, char, 1, fn val -> val + 1 end)
      end)

    queue =
      freq
      |> Enum.sort_by(fn {_char, frequency} -> frequency end)
      |> Enum.map(fn {key, frequency} ->
        {%Leaf{key: key},frequency}
      end)
  end

  # defp = define private method.
  def huffman_tree([{root, _freq}]) do root end
  def huffman_tree([{node_a, freq_a}, {node_b, freq_b} | rest]) do

    new_node = %Node{
      left: node_a,
      right: node_b
    }

    total = freq_a + freq_b
    queue = [{new_node, total}] ++ rest

    queue
    |> Enum.sort_by(fn {_node, frequency} -> frequency end)
    |> huffman_tree()
  end

  # if value is the same as character return path without using character (^)
  # fill tree with ones and zeroes.
  def find(tree, character, path \\ [])
  def find(%Leaf{key: key}, character, path) do
    case key do
      ^character -> {character, Enum.reverse(path)}
      _ -> nil
    end
  end
  #depth first?
  def find(%Node{left: left, right: right}, character, path) do
    find(left, character, [0|path]) ||
    find(right, character, [1|path])
  end

  def encode(sample \\ sample()) do

    map = table(sample)
    # [] = acc
    Enum.reduce(map, [], fn {_, single_element_map}, acc -> acc ++ single_element_map end)
  end

  # converts from ASCII to character.
  def to_atom_list(sample, acc \\ [])
  def to_atom_list([], acc) do acc end
  def to_atom_list([char | rest], acc) do
    to_atom_list(rest, [List.to_string([char])| acc])
  end

  def decode([], _) do [] end

  #table = [{:a, 101}, {:b, 120102}...]
  #seq = 101001010101
  #1 = where to split
  def decode(seq, table) do
    {char, rest} = decode_char(seq, 1, table)
    list = [char | decode(rest, table)]
    List.to_string(list)
  end

  # {1/0, 101010101010} n = 1
  # (table, code, 1) 1 = which part of the tuple to look at {0, 1}.
  # is there any entry in the 'table' that has the code 1/0.
  def decode_char(seq, n, table) do
    {code, rest} = Enum.split(seq, n)
    case List.keyfind(table, code, 1) do
      {char, _} -> {char, rest}
      nil -> decode_char(seq, n + 1, table)
    end
  end

  def table(sample) do
    tree = freq(sample)
    |> huffman_tree()
    sample = to_atom_list(sample)
    map = Enum.map(sample, fn char -> find(tree, char) end)
    map = Enum.reverse(map)
  end

  # This is the benchmark of the single operations in the
  # Huffman encoding and decoding process.

  def bench(file, n) do
    {text, b} = read(file, n)
    c = length(text)
    {tree, t2} = time(fn -> huffman_tree(freq(text)) end)
    {table, t3} = time(fn -> table(text) end)
    s = length(table)
    {encoded, t5} = time(fn -> encode(text) end)

    e = div(length(encoded), 8)
    r = Float.round(e / b, 3)
    {_, t6} = time(fn -> decode(encoded, table) end)

    IO.puts("text of #{c} characters")
    IO.puts("tree built in #{t2} ms")
    IO.puts("table of size #{s} in #{t3} ms")
    IO.puts("encoded in #{t5} ms")
    IO.puts("decoded in #{t6} ms")
    IO.puts("source #{b} bytes, encoded #{e} bytes, compression #{r}")
  end

  def time(func) do
    initial = Time.utc_now()
    result = func.()
    final = Time.utc_now()
    {result, Time.diff(final, initial, :microsecond) / 1000}
  end

 # Get a suitable chunk of text to encode.
  def read(file, n) do
   {:ok, fd} = File.open(file, [:read, :utf8])
    binary = IO.read(fd, n)
    File.close(fd)

    length = byte_size(binary)
    case :unicode.characters_to_list(binary, :utf8) do
      {:incomplete, chars, rest} ->
        {chars, length - byte_size(rest)}
      chars ->
        {chars, length}
    end
  end


end
