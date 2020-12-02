# Solution to Day 1 Puzzles

Both puzzles on Day 1 shared the same form of:

1. Take a list of numbers
2. Find a sub-set that sum to a specific number
3. Print the product of that subset's contents

The only difference between the two puzzles was the 
length of the subset - 2 for the first puzzle and 3
for the second. 

Although the list of input numbers wasn't long, I 
opted for a dynamic programming approach to force
learning more about Julia. After some iteration, I 
settled on a single implementation capable of solving
both puzzles.

The main dynamic programming function was,

```julia 
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
```


I also implemented a simple optimization of:
1. Sorting the input values
2. Early terminating the DP recursion if the current sum exceeds the target


To solve the first puzzle, that function is called as follows,

```julia

  solutions = Array{Array{Int64,1},1}()
  findCombosThatSumToVal!(entries, 2020, 2, Int64[], solutions)
```

Any solutions, if found, will be in the solutions array upon return. 

The full solution can be run from the command line with the following arguments,

```
% julia soln_d01.jl --help
usage: soln_d01.jl [-h] input sum count

positional arguments:
  input       Input file
  sum         Target Sum (type: Int64)
  count       Number of values to sum (type: Int64)

optional arguments:
  -h, --help  show this help message and exit
```
