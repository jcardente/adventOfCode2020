# Solution to Day 5 Puzzle

Day five required decoding boarding pass seat IDs represented as a 10
character ASCII string. The first 7 characters represent the row and
remaining 3 charaters the seat within the row (eg the column). Each
row and column value is encoded as a binary number with different
characters representing a 1 and 0.  For row values, a `B` is a `1` and
`F` a `0`. For columns, `R` is a `1` and `L` is a `0`. For example,
the seat id `FBFBBFFRLR` decodes to row 44 and column 5. The final
seatid is calculated by multipling the row by 8 and adding the result
to the column, in this case `8 * 44 + 5 = 357`.

Part 1 asks for the maximum seat id in the provided input data. Part 2
asks to find the (only) missing seat id for which the previous and
subsequent value exists in the input data.

I wrote the following generic function to decide the ASCII encoded
binary values,

```julia
function decodeBPString(vstr, oneChar)
  val = 0
  for c in collect(vstr)
    val = (val << 1) | ((c==oneChar) ? 1 : 0)
  end
  return val
end
```

That function was then used to decode each seat id in the input
data,

```julia
seatIds = Int[]
for bp in boardingPasses
  row = decodeBPString(SubString(bp, 1:7), 'B')
  col = decodeBPString(SubString(bp, 8:10), 'R')
  seatId = row*8 + col    
  push!(seatIds, seatId) 
end
```

For part 1, I just passed the list of seat IDs to Julia's `max()` function. For part
2, I sorted the list of IDs and simply looked for the first adjacent pair of values
that differed by 2. 

```julia
sort!(seatIds)
mySeat = 0
for i in 1:(length(seatIds)-1)
  if (seatIds[i]+2) == seatIds[i+1]
    mySeat = seatIds[i]+1
    break
  end
end
@printf("My seat id is %d\n", mySeat)
```

The final solution can be executed from the command line with the following arguments.

```
% julia soln_day05.jl --help         
usage: soln_day05.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
