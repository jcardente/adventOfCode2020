# Day 18 Solutions

[Day 18](https://adventofcode.com/2020/day/17) required parsing and evaluating infix
math equations with non-standard operator precedance rules. 

The puzzle input were equations such as,

```
2 * 3 + (4 * 5)
5 + (8 * 3 + 9 + 3 * 4 * 3)
5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4))
((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2
```

In part 1, the addition and multiplication operators had **equal** precedence
and evaluated left to right. For example, 

```
1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
      9   + 4 * 5 + 6
         13   * 5 + 6
             65   + 6
                 71
```

Parenthesis, however, could override the order as in normal math
equations. For example, 

```
1 + (2 * 3) + (4 * (5 + 6))
1 +    6    + (4 * (5 + 6))
     7      + (4 * (5 + 6))
     7      + (4 *   11   )
     7      +     44
            51
```

In part 2, addition had a higher precendence than multiplication. For example, 

```
1 + 2 * 3 + 4 * 5 + 6
  3   * 3 + 4 * 5 + 6
  3   *   7   * 5 + 6
  3   *   7   *  11
     21       *  11
         231
```

To start, I created objects and methods to represent and evaluate literals and operators,

```julia
abstract type Expression end

struct Literal <: Expression
  value::Int
end


struct Op <: Expression
  op::Char
  left::Expression
  right::Expression
end


function evalExpression(e::Literal)
  e.value
end


function evalExpression(e::Op)
  lval = evalExpression(e.left)
  rval = evalExpression(e.right)

  if e.op == '+'
    r = lval + rval
  elseif e.op == '*'
    r = lval * rval
  else
    error(@sprintf("Unknow op %c",e.op))
  end

  return r
end
```


This allowed creating and evaluating an 
[abstract syntax tree](https://en.wikipedia.org/wiki/Abstract_syntax_tree)
of expressions.

I found parsing the infix notation to create an AST to be really
challenging as I haven't had a lot of experience in this area. After
experimenting with a couple of approaches, I did a little research and
found [Dijkstra's](https://en.wikipedia.org/wiki/Edsger_W._Dijkstra)
[Shunting Yard](https://en.wikipedia.org/wiki/Shunting-yard_algorithm)
algorithm.

I wrote a routine that implemented the algorithm to build an AST from
infix expressions. The routine also took, as an argument, the operator priorities
which allowed it to solve both parts of the puzzle. 

```julia
function shuntingYard(s, opPriorities)
  operands = Expression[]
  opstack  = Char[]

  idx = 1
  while idx <= length(s)
    if isdigit(s[idx])
      # Parse digit and add literal expression to operands
      # stack
      eidx = idx+1
      while eidx <=length(s) && isdigit(s[eidx])
        eidx+=1
      end
      val = parse(Int,s[idx:eidx-1])
      push!(operands, Literal(val))
      idx = eidx-1
      
    elseif s[idx] in ['+','*']
      op = s[idx]
      while ((length(opstack) > 0) &&
             (opPriorities[last(opstack)] >=  opPriorities[s[idx]]))

        op   = pop!(opstack)
        if op in ['+','*']
          rhs  = pop!(operands)
          lhs  = pop!(operands)       
          expr = Op(op, lhs, rhs)
          push!(operands, expr)
        end        
      end
      push!(opstack, s[idx])

    elseif s[idx] == ')'
      op = pop!(opstack) 
      while op != '(' 
        if op in ['+', '*']
          rhs  = pop!(operands)
          lhs  = pop!(operands)
          expr = Op(op, lhs, rhs)

          push!(operands, expr)
        else
          erorr("Shouldn't get here")
        end
        op = pop!(opstack) 
      end      
      
    elseif s[idx] == '('
      push!(opstack, '(')

    end
    
    idx+=1
  end
  
  while length(opstack) > 0
    op = pop!(opstack)    
    if op in ['+', '*']
      rhs = pop!(operands)
      lhs = pop!(operands)
      expr = Op(op, lhs, rhs)

      push!(operands, expr)
    end
  end

  # Operand on top of stack should be root
  # of the expression tree.
  return evalExpression(operands[1])
end
```

Solving the puzzle parts was then just a matter of calling the routine
with the input and appropriate operator priorities,

```julia
lines = inputLoad(args["input"])

if args["part"] == "part1"
  opPriorities = Dict('+' => 1, '*' => 1, '(' => 0)
    
else
  opPriorities = Dict('+' => 2, '*' => 1, '(' => 0)
end
  
  
results = Int64[]
for l in lines  
  result = shuntingYard(l, opPriorities)      
  push!(results, result)
end

finalsum = sum(results)
@printf("Sum of answers: %d\n", finalsum)
```

Final solution can be run from the command line,

```
% julia soln_day18.jl -h
usage: soln_day18.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
