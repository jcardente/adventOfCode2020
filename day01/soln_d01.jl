# ------------------------------------------------------------
# Solution to Advent of Code 2020 Day 1
#
# PUZZLE:
#
# Before you leave, the Elves in accounting just need you to fix your
# expense report (your puzzle input); apparently, something isn't quite
# adding up.
#
# Specifically, they need you to find the two entries that sum to 2020
# and then multiply those two numbers together.
#
# For example, suppose your expense report contained the following:
#
# 1721
# 979
# 366
# 299
# 675
# 1456
#
# In this list, the two entries that sum to 2020 are 1721 and
# 299. Multiplying them together produces 1721 * 299 = 514579, so the
# correct answer is 514579.
#
# Of course, your expense report is much larger. Find the two entries
# that sum to 2020; what do you get if you multiply them together?
#
# --- Part Two ---
#
# The Elves in accounting are thankful for your help; one of them even
# offers you a starfish coin they had left over from a past
# vacation. They offer you a second one if you can find three numbers in
# your expense report that meet the same criteria.
#
# Using the above example again, the three entries that sum to 2020 are
# 979, 366, and 675. Multiplying them together produces the answer,
# 241861950.
#
# In your expense report, what is the product of the three entries that
# sum to 2020?

using Printf
using ArgParse


function inputLoad(fname)
  entries = Int[]
  open(fname, "r") do f
    for line in readlines(f)
      entry = parse(Int, line)
      push!(entries, entry)
    end
  end
  return entries
end


function findCombosThatSumToVal!(values, target_sum, num_values, candidates, solutions)
  if length(candidates) == num_values
    if sum(candidates) == target_sum
      # NB - found a solution!
      push!(solutions, candidates)
    end
    return
      
  elseif (length(values) + length(candidates)) < num_values
    # NB - no possible solution not enough values left
    return
    
  elseif sum(candidates) > target_sum
    # NB - Sum of current candidates exceeds target sum, terminate early. 
    #      Requires values to be sorted in ascending order
    return
    
  else
    # Try with this value
    rest = @view values[2:length(values)]
    new_candidates = copy(candidates)
    push!(new_candidates, values[1])
    
    findCombosThatSumToVal!(rest, target_sum, num_values, new_candidates, solutions)

    # Try without this value
    findCombosThatSumToVal!(rest, target_sum, num_values, candidates, solutions)
        
  end
end


function parseCommandLine()
  s = ArgParseSettings()

  @add_arg_table s begin
    "input"
      help = "Input file"
      required = true
    "sum"
      help = "Target Sum"
      required = true
      arg_type = Int64
    "count"
      help = "Number of values to sum"
      required = true
      arg_type = Int64
  end

  return parse_args(s)
end



function main()
  args = parseCommandLine()
  
  entries = inputLoad(args["input"])
  sort!(entries)

  solutions = Array{Array{Int64,1},1}()
  findCombosThatSumToVal!(entries, args["sum"], args["count"], Int64[], solutions)

  if length(solutions) == 1
    soln = reduce(*, solutions[1])
    @printf("Solution is: %s = %d \n",
            join(string.(solutions[1]), " * "),
            soln)
    
  elseif length(solutions) > 1
    @printf("Uhoh found %d solutions", length(solutions))
    
  else
    println("No solutions found")
  end
end


main()
