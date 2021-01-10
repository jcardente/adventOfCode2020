# Day 19 Solutions

For [Day 19](https://adventofcode.com/2020/day/19), the task was to determine
if character strings satisfied patterns expressed as a recursive set of rules.

The rules took the form,

```
0: 1 2
1: "a"
2: 1 3 | 3 1
3: "b"
```

In this example, rules 1 and 3 are primitives that specify the required
character. Rules 0 and 2 are a combinations of two or more sub-rules. in rule
2, the `|` character indicates an OR condition.

In part 1, the rules did not have any loops. Part 2 slightly modified the puzzle
input to add loops. 

I stored the rules in a dictionary indexed by rule number with the sub-clauses
as contents. The sub-clauses were represented as a list of list of strings. Primitive
rules only had one string list containing one character. Compound rules contained one
or more string lists each storing the sub-rule numbers for each clause.

I then wrote a routine that recursively validated patterns using a dynamic programming
algorithm. It basically expanded rules one at a time until a primitive rule was reached. 
It then checked to see if current input string character matched the primitive rule.
If not, the routine terminated. If so, then position in the input string was advanced
and the next rule evaluated. The routine also terminated if the end of the input string 
was reached before all the rules were matched.

```julia
function checkRule(rids, rules, s, idx)
  
  if length(rids) == 0
    if idx  > length(s)
      # Pattern found! return true
      return true
      
    else
      # Pattern exhausted before of string
      return false
    end
    
  elseif idx > length(s)
    # End of string before rules
    return false
    
  end
  
  rid   =  rids[1]
  clauses = rules[rid]
  ok      = false
  for c in clauses
    if (length(c) == 1 && isletter(c[1][1]))
      if s[idx] == c[1][1]
        # Rule OK, continue to next
        ok |= checkRule(rids[2:end], rules, s, idx+1)
      end
     
    else
      # Composite, expand and recurse
      nextrids = vcat(c, rids[2:end])
      ok |= checkRule(nextrids, rules, s, idx)
             
    end

    # Early termination, if ok true
    # don't test any more!
    if ok
      break
    end
  end

  return ok
end
```

Fortunately, the algorithm's design allowed it to solve parts 1 and 2 without change.

Final solution can be run from the command line,

```
% julia soln_day19.jl -h
usage: soln_day19.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
