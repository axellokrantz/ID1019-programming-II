defmodule Derivates do

  # Literal could be a number or a variable.
  # Expression could be a literal (number or x)
  # or two expressions addition
  # or two expressions multiplication
  # or an expression multiplicated with an variable or a number.

  @type literal() :: {:num, number()} | {:var, atom()}
  @type expr() ::  literal()
  | {:add, expr(), expr()}
  | {:mul, expr(), expr()}
  | {:exp, expr(), literal()}
  | {:ln, expr()}
  | {:sqrt, expr()}
  | {:sin, expr()}
  | {:cos, expr()}

  def test1() do
    e = {:add, {:sin, {:mul, {:num, 2}, {:var, :x}}}, {:num, 4}}
    d = derive(e, :x)
    # Calculates the derivated expression with a given x.
    c = calc(d, :x, 5)
    IO.write("Expression: #{pprint(e)}\n")
    IO.write("Derivate: #{pprint(d)}\n")
    IO.write("Simplified: #{pprint(simplify(d))}\n")
    IO.write("Calculated: #{pprint(simplify(c))}\n")
    :ok
  end

  def test2() do
    e = {:add, {:ln, {:mul, {:num, 3}, {:var, :x}}}, {:num, 4}}
    d = derive(e, :x)
    c = calc(d, :x, 4)
    IO.write("Expression: #{pprint(e)}\n")
    IO.write("Derivate: #{pprint(d)}\n")
    IO.write("Simplified: #{pprint(simplify(d))}\n")
    IO.write("Calculated: #{pprint(simplify(c))}\n")
    :ok
  end

  def derive({:num, _},_) do {:num, 0} end
  def derive({:var, v}, v) do {:num, 1} end
  def derive({:var, _}, _) do {:num, 0} end
  def derive({:add, e1, e2}, v) do
    {:add, derive(e1, v), derive(e2, v)}
  end
  def derive({:mul, e1, e2}, v) do
    {:add,
      {:mul, derive(e1, v), e2},
      {:mul, e1, derive(e2, v)}}
  end
  def derive({:exp, e, {:num, n}}, v) do
    {:mul,
      {:mul, {:num, n}, {:exp, e, {:num, n-1}}},
      derive(e, v)}
  end
  def derive({:ln, {:num, _}}, _) do {:num, 0} end
  def derive({:ln, e}, v) do {:mul, {:exp, e, {:num, -1}}, derive(e, v)} end

  def derive({:sqrt, {:num, _}}, _) do {:num, 0} end
  def derive({:sqrt, e}, v) do {:mul, derive(e, v), {:mul, {:exp, e, {:num, -0.5}}, {:num, 0.5}}} end
  def derive({:sin, {:num, _}}, _) do {:num, 0} end
  def derive({:sin, e}, v) do {:mul, derive(e, v), {:cos, e}} end
  def derive({:cos, {:num, _}}, _) do {:num, 0} end
  def derive({:cos, e}, v) do {:mul, derive(e, v), {:mul, -1, {:sin, e}}} end

  def calc({:num, n}, _, _) do {:num, n} end
  def calc({:var, v}, v, n) do {:num, n} end
  def calc({:var, v}, _, _) do {:var, v} end
  def calc({:add, e1, e2}, v, n) do {:add, calc(e1, v, n), calc(e2, v, n)} end
  def calc({:mul, e1, e2}, v, n) do {:mul, calc(e1, v, n), calc(e2, v, n)} end
  def calc({:exp, e1, e2}, v, n) do {:exp, calc(e1, v, n), calc(e2, v, n)} end
  def calc({:ln, e1}, v, n) do {:ln, calc(e1, v, n)} end
  def calc({:sqrt, e1}, v, n) do {:exp, calc(e1, v, n), {:num, 0.5}} end
  def calc({:sin, e1}, v, n) do {:sin, calc(e1, v, n)} end
  def calc({:cos, e1}, v, n) do {:cos, calc(e1, v, n)} end

  def simplify({:add, e1, e2}) do
    simplify_add(simplify(e1), simplify(e2))
  end

  def simplify({:mul, e1, e2}) do
    simplify_mul(simplify(e1), simplify(e2))
  end

  def simplify({:exp, e1, e2}) do
    simplify_exp(simplify(e1), simplify(e2))
  end

  def simplify({:ln, e1}) do simplify_ln({:ln, simplify(e1)}) end
  def simplify({:sin, e1}) do simplify_sin({:sin, simplify(e1)}) end
  def simplify({:cos, e1}) do simplify_cos({:cos, simplify(e1)}) end

  # if none of the simplify functions work, return what we had.
  def simplify(e) do e end

  def simplify_add({:num, 0}, e2) do e2 end
  def simplify_add(e1, {:num, 0}) do e1 end
  def simplify_add({:num, n1}, {:num, n2}) do {:num, n1 + n2} end
  def simplify_add(e1, e2) do {:add, e1, e2} end

  def simplify_mul({:num, 0}, _) do {:num, 0} end
  def simplify_mul(_, {:num, 0}) do {:num, 0} end
  def simplify_mul({:num, 1}, e1) do e1 end
  def simplify_mul(e2, {:num, 1}) do e2 end
  def simplify_mul({:num, n1}, {:num, n2}) do {:num, n1 * n2} end
  def simplify_mul(e1, e2) do {:mul, e1, e2} end

  def simplify_exp(_, {:num, 0}) do {:num, 1} end
  def simplify_exp(e1, {:num, 1}) do e1 end
  def simplify_exp({:num, n1}, {:num, n2}) do {:num, :math.pow(n1,n2)} end
  def simplify_exp(e1, e2) do {:exp, e1, e2} end

  def simplify_ln({:ln, {:num, 1}}) do {:num, 0} end
  def simplify_ln({:ln, {:num, n1}}) do {:num, :math.log(n1)} end
  def simplify_ln(e1) do e1 end

  def simplify_sin({:sin, {:num, n1}}) do {:num, :math.sin(n1)} end
  def simplify_sin(e1) do e1 end

  def simplify_cos({:cos, {:num, n1}}) do {:num, :math.cos(n1)} end
  def simplify_cos(e1) do e1 end

  def pprint({:num, n}) do "#{n}" end
  def pprint({:var, v}) do "#{v}" end
  def pprint({:add, e1, e2}) do "(#{pprint(e1)} + #{pprint(e2)})" end
  def pprint({:mul, e1, e2}) do "#{pprint(e1)} * #{pprint(e2)}" end
  def pprint({:exp, e1, e2}) do "(#{pprint(e1)}) ^ (#{pprint(e2)})" end
  def pprint({:ln, e1}) do "ln(#{pprint(e1)})" end
  def pprint({:sqrt, e1}) do "sqrt(#{pprint(e1)})" end
  def pprint({:sin, e1}) do "sin(#{pprint(e1)})" end
  def pprint({:cos, e1}) do "cos(#{pprint(e1)})" end
  def pprint(e1) do "#{e1}" end

end
