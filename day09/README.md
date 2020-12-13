# Solution to Day 9 Puzzles

[Day 9](https://adventofcode.com/2020/day/9) involved
"cracking" a simple encryption scheme. 

The input to both puzzles is a sequence of integers. After an initial
preamble, valid values in the sequence must be the sum of two previous
values within a fixed size trailing window.

Part 1 asks to find the first invalid value in the input sequence. I wrote
the following routine to find the sum of all pairs of values in a list,


```julia
function findPairSums(values)
  n = length(values)
  sums = Set()
  for i in 1:(n-1)
    for j in i:n
      if values[i] != values[j]
        push!(sums, values[i] + values[j])
      end
    end
  end

  return [sums...]
end
```

To find the first invalid sequence value, the following code iterated
over each value, computed the possible sums from the trailing window, and
checked if the value was a sum,

```julia
npreamble = 25  
idx = npreamble +1
while idx <= length(data)
  validValues = findPairSums(data[(idx-npreamble):(idx-1)])
  if !(data[idx] in validValues)
    break
  end
  idx +=1
end
```

I considered more efficient ways to maintain the list of sums but
this solution worked well enough for the competition input.

Part 2 asked to find a contiguous set of values in the input
sequence that sum to the invalid value found in Part 1. For this, 
I wrote a routine that used two indexes to form a rolling window
over the input sequence that expanded and contracted as needed.

```julia
function findContiguous(targetval, values)
  startidx = 1
  endidx   = 2
  maxidx   = length(values)
  found    = false
  while !found && (startidx < length(values))
    currentsum = sum(values[startidx:endidx])

    if (currentsum == targetval) && (startidx < endidx)
      # Contiguous range found!
      found = true
      break
      
    elseif currentsum > targetval
      # Current range sum too big, move window forward
      startidx +=1

    else
      # Current range sum too small, expand
      endidx = min(endidx+1, maxidx)
      
    end
  end

  if !found
    return nothing, nothing
  end

  return startidx, endidx 
end
```

Final solution can be run from the command line using the following arguments,

```
% julia soln_day09.jl --help
usage: soln_day09.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
