defmodule Eval do

  @type expr() :: {:add, expr(), expr()}
  | {:sub, expr(), expr()}
  | {:mul, expr(), expr()}
  | {:div, expr(), expr()}
  | literal()

  @type literal() :: {:num, number()} | {:var, atom()} | {:q, number(), number()}

  def env([{var, val}]) do [{{:var, var}, {:num, val}}] end
  def env([{var, val}|tail]) do [{{:var, var}, {:num, val}} | env(tail)] end
  def env({:var, var}, []) do {:var, var} end
  def env({:var, var}, [{{:var, var}, {:num, val}}|_]) do {:num, val} end
  def env({:var, var}, [{{:var, _}, {:num, _}}|tail]) do env({:var, var}, tail) end

  def eval(:undefined, _) do :error end
  def eval({:num, n}, _) do {:num, n} end
  def eval({:var, v}, env) do env({:var, v}, env) end
  def eval({:q, q1, q2}, _) do reduce({:q, q1, q2}) end

  def eval({:add, e1, e2}, env) do eval(add(eval(e1, env), eval(e2, env)), env) end
  def eval({:sub, e1, e2}, env) do eval(sub(eval(e1, env), eval(e2, env)), env) end
  def eval({:mul, e1, e2}, env) do eval(mul(eval(e1, env), eval(e2, env)), env) end
  def eval({:div, e1, e2}, env) do eval(division(eval(e1, env), eval(e2, env)), env) end

  def reduce({:q, _, 0}) do :error end
  def reduce({:q, 0, _}) do {:num, 0} end
  def reduce({:q, q1, q2}) when rem(q1, q2) == 0 do {:num, div(q1,q2)} end
  def reduce({:q, q1, q2}) do
    gcd = Integer.gcd(q1, q2)
    {:q, div(q1, gcd), div(q2,gcd)}
  end

  def add({:num, n1}, {:num, n2}) do {:num, n1 + n2} end
  def add({:q, q1, q2}, {:q, q3, q2}) do {:q, (q1 + q3), q2} end
  def add({:q, q1, q2}, {:num, n}) do {:q, (n * q2) + q1, q2} end
  def add({:num, n}, {:q, q1, q2}) do {:q, (n * q2) + q1, q2} end
  def add({:q, q1, q2}, {:q, q3, q4}) do {:q, (q1 * q4) + (q3 * q2), (q2 * q4)} end

  def sub({:num, n1}, {:num, n2}) do {:num, n1 - n2} end
  def sub({:q, q1, q2}, {:q, q3, q2}) do {:q, (q1 - q3), q2} end
  def sub({:q, q1, q2}, {:num, n}) do {:q, q1 - (n * q2), q2} end
  def sub({:num, n}, {:q, q1, q2}) do {:q, (n * q2) - q1, q2} end
  def sub({:q, q1, q2}, {:q, q3, q4}) do {:q, (q1 * q4) - (q3 * q2), (q2 * q4)} end

  def mul({:num, 0}, _) do {:num, 0} end
  def mul(_, {:num, 0}) do {:num, 0} end
  def mul({:num, n1}, {:num, n2}) do {:num, n1 * n2} end
  def mul({:num, n}, {:q, q1, q2}) do {:q,  n * q1, q2} end
  def mul({:q, q1, q2}, {:num, n}) do {:q,  n * q1, q2} end
  def mul({:q, q1, q2}, {:q, q3, q4}) do {:q, q1 * q3, q2 * q4} end

  def division(_, {:num, 0}) do :undefined end
  def division({:num, 0}, _) do {:num, 0} end
  def division({:num, n1}, {:num, n2}) do {:q, n1, n2} end
  def division({:q, q1, q2}, {:q, q3, q4}) do {:q, (q1 * q4), (q3 * q2)} end
  def division({:q, q1, q2}, {:num, n}) do {:q, q1, (q2 * n)} end
  def division({:num, n}, {:q, q1, q2}) do {:q, (n * q2), q1} end

end
