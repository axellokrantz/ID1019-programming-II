defmodule EnvTree do

  def new() do nil end

  # if tree is empty.
  def add(nil, key, value) do
    {:node, key, value, nil, nil}
  end

  # if we found a match, we update the value.
  def add({:node, key, _, left, right}, key, value) do
    {:node, key, value, left, right}
  end

  # Iterate left or right.
  def add({:node, k, v, left, right}, key, value) do
    if key < k do
      {:node, k, v, add(left, key, value), right}
    else
      {:node, k, v, left, add(right, key, value)}
    end
  end

  def lookup(nil, _) do nil end
  def lookup({:node, key, value, _, _}, key) do {key, value} end
  def lookup({:node, k, _, left, right}, key) do
    if key < k do
      lookup(left, key)
    else
      lookup(right, key)
    end
  end

  # removing from an empty tree, or base case where key was not found.
  def remove(nil, _) do nil end

  # Key found. * If key > k, we return the right node.
  def remove({:node, key, _, nil, right}, key) do right end
  # Key found. * If key < k, we return the left node.
  def remove({:node, key, _, left, nil}, key) do left end

  # Key found. Nodes on both sides. Get value from left most node in right branch.
  # Update the node we want to delete with the values of the nodes left most in the right branch.
  def remove({:node, key, _, left, right}, key) do
    {key, value, rest} = leftmost(right)
    {:node, key, value, left, rest}
  end


  #if key was not found we itterate either left or right.
  def remove({:node, k, v, l, r}, key) do
    if key < k do
      # * Update reference to new left node.
      {:node, k, v, remove(l, key), r}
    else
      # * Update reference to new right node.
      {:node, k, v, l, remove(r, key)}
    end
  end

  # We're looking for the left most node. There is no node to the left.
  # We return the key, value and the pointer to the node to the right.
  # Since we update the pointer, there is no longer any node pointing
  # at the node we want to delete.
  def leftmost({:node, key, value, nil, rest}) do {key, value, rest} end

  # Looking for a replacement for the node we want to replace. The value will (according to the algorithm)
  # be the left most node in the nodes right branch.
  # 'rest' is the left most nodes right branch.
  def leftmost({:node, k, v, left, right}) do
    {key, value, rest} = leftmost(left)
    {key, value, {:node, k, v, rest, right}}
  end

end
