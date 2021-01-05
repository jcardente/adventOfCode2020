# ------------------------------------------------------------
# Solution to Advent of Code 2020 Puzzle Day 18
#
# PUZZLE:
#
# --- Day 18: Operation Order ---
# 
# As you look out the window and notice a heavily-forested continent
# slowly appear over the horizon, you are interrupted by the child
# sitting next to you. They're curious if you could help them with
# their math homework.
# 
# Unfortunately, it seems like this "math" follows different rules
# than you remember.
# 
# The homework (your puzzle input) consists of a series of expressions
# that consist of addition (+), multiplication (*), and parentheses
# ((...)). Just like normal math, parentheses indicate that the
# expression inside must be evaluated before it can be used by the
# surrounding expression. Addition still finds the sum of the numbers
# on both sides of the operator, and multiplication still finds the
# product.
# 
# However, the rules of operator precedence have changed. Rather than
# evaluating multiplication before addition, the operators have the
# same precedence, and are evaluated left-to-right regardless of the
# order in which they appear.
# 
# For example, the steps to evaluate the expression 1 + 2 * 3 + 4 * 5 + 6
# are as follows:
# 
# 1 + 2 * 3 + 4 * 5 + 6
#   3   * 3 + 4 * 5 + 6
#       9   + 4 * 5 + 6
#          13   * 5 + 6
#              65   + 6
#                  71
# 
# Parentheses can override this order; for example, here is what
# happens if parentheses are added to form 1 + (2 * 3) + (4 * (5 +
# 6)):
# 
# 1 + (2 * 3) + (4 * (5 + 6))
# 1 +    6    + (4 * (5 + 6))
#      7      + (4 * (5 + 6))
#      7      + (4 *   11   )
#      7      +     44
#             51
# 
# Here are a few more examples:
# 
# - 2 * 3 + (4 * 5) becomes 26.
# - 5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 437.
# - 5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 12240.
# - ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 13632.
# 
# Before you can help with the homework, you need to understand it
# yourself. Evaluate the expression on each line of the homework; what
# is the sum of the resulting values?
#
# --- Part Two ---
# 
# You manage to answer the child's questions and they finish part 1 of
# their homework, but get stuck when they reach the next section:
# advanced math.
# 
# Now, addition and multiplication have different precedence levels,
# but they're not the ones you're familiar with. Instead, addition is
# evaluated before multiplication.
# 
# For example, the steps to evaluate the expression 1 + 2 * 3 + 4 * 5
# + 6 are now as follows:
# 
# 1 + 2 * 3 + 4 * 5 + 6
#   3   * 3 + 4 * 5 + 6
#   3   *   7   * 5 + 6
#   3   *   7   *  11
#      21       *  11
#          231
# 
# Here are the other examples from above:
# 
# 1 + (2 * 3) + (4 * (5 + 6)) still becomes 51.
# 2 * 3 + (4 * 5) becomes 46.
# 5 + (8 * 3 + 9 + 3 * 4 * 3) becomes 1445.
# 5 * 9 * (7 * 3 * 3 + 9 * 3 + (8 + 6 * 4)) becomes 669060.
# ((2 + 4 * 9) * (6 + 9 * 8 + 6) + 6) + 2 + 4 * 2 becomes 23340.
# 
# What do you get if you add up the results of evaluating the homework
# problems using these new rules?

using Printf
using ArgParse


function inputLoad(fname)
  lines = readlines(fname)
end


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

string(l::Literal) = @sprintf("%d", l.value)

function string(o::Op)
  lhs = string(o.left)
  if typeof(o.left) == Op
    lhs = @sprintf("(%s)", lhs)
  end

  rhs = string(o.right)
  if typeof(o.right) == Op
    rhs = @sprintf("(%s)", rhs)
  end

  return @sprintf("%s %c %s", lhs, o.op, rhs)
end


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
      #@printf("Pushed to operands %s\n", string(Literal(val)))
      
    elseif s[idx] in ['+','*']
      #@printf("Found op %c, checking priorities \n",s[idx])
      #@printf("remaining ops: %s\n", join(opstack,','))
      op = s[idx]
      while ((length(opstack) > 0) &&
             (opPriorities[last(opstack)] >=  opPriorities[s[idx]]))

        op   = pop!(opstack)
        #@printf("Popping %c\n", op)

        if op in ['+','*']
          rhs  = pop!(operands)
          lhs  = pop!(operands)       
          expr = Op(op, lhs, rhs)

          #@printf("Pushing %s\n", string(expr))
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
      #@printf("Pushing %c\n", s[idx])      
      push!(opstack, '(')

    end
    
    idx+=1
  end
  #@printf("\nLoop ended\n")
  #@printf("remaining ops: %s\n", join(opstack,','))
  #@printf("remaining operands:\n")
  #for o in operands
  #  println(string(o))
  #end
  
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
  #@printf("Final expression %s\n", string(operands[1]))
  return evalExpression(operands[1])
end


function parseCommandLine()
  s = ArgParseSettings()
  @add_arg_table s begin
    "input"
      help = "Input file"
      required = true
    "part"
      help = "Part to solve, part1 or part2"
      required = true
  end

  return parse_args(s)
end


function main()  
  args  = parseCommandLine()  
  lines = inputLoad(args["input"])

  if args["part"] == "part1"
    opPriorities = Dict('+' => 1, '*' => 1, '(' => 0)
    
  else
    opPriorities = Dict('+' => 2, '*' => 1, '(' => 0)
  end
  
  
  results = Int64[]
  for l in lines  
    result = shuntingYard(l, opPriorities)
      
    #println("----")
    #@printf("%d = %s\n", result, l)
    push!(results, result)
  end

  finalsum = sum(results)
  @printf("Sum of answers: %d\n", finalsum)

end

main()
