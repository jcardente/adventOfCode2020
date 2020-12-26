# Day 10 solution

[Day 10](https://adventofcode.com/2020/day/10) involved
finding chains of "power adapters" that achieve
a target "Jolt" value. In order for a chain
to be valid, the "Jolt" difference between consecutive
adapters had to be between 1 and 3.

Part 1 required finding a chain that used all of the
adapters, counting the number of 1 and 3 Jolt differences,
and then reporting their product. 

The only valid chain was the adapter values sorted in ascending order.
Counting the differences using a list comprehension and counter
was straight forward,


```julia
sort!(jolts);
maxJolt = last(jolts)
chain   = vcat([0], jolts, [maxJolt+3])
diffs   = [chain[i]-chain[i-1] for i in 2:length(chain)]
diffCounts  = counter(diffs)
p1soln = diffCounts[3] * diffCounts[1]
```

Part 2 was... trickier. It asked for the number of valid adapter
chains. The input data was designed to make the number of valid chains
very, very large. So much so that recursive solutions more or less
blew up.

I admit to falling into the recursion trap. I initially wrote a
dynamic programming solution that pruned invalid paths as soon as they
were detected. I thought this approach would be compute and memory
efficient. Nope. I initially suspected that I did something
inappropriate in Julia, like unintentionally coping arrays rather than
sharing references. I finally realized that there were too many valid
chains to find recursively.

At that point, I remembered a very simple non-recursive dynamic
programming algorithm that I learned while prepping for coding
interviews. The basic steps were:

1. Create a vector of zeroes with a length equal to the final jolt value
2. Sort the power adapter values in increasing order
3. Loop over the power adapters in order and,
    - If the adapter's jolt is less then or equal to 3, initialize
      the vector value at the jolt index to 1
    - Regardless, add the vector value at the jolt index to the next
      three vector indexes

When done, the vector contains the number of adapter combinations that
lead to jolt value associated with each index. Therefore, the last
vector value contains the number of valid combinations that achieve
the target jolt value. Super simple algorithm with O(N) runtime
and storage (excluding the initial sort).

The code that implemented this was,

```julia
sort!(jolts)
maxJolt = last(jolts)

counts = zeros(Int64, maxJolt+3)

for j in jolts
  if j <= 3
    # NB - possible starting point, seed count with 1
    counts[j] += 1
  end
      
  counts[j+1] += counts[j]
  counts[j+2] += counts[j]
  counts[j+3] += counts[j]
end
@printf("Part 2: found %d adapter chains that work\n", counts[end])
```

Final solution can be run from the command line using the following arguments,

```
% julia soln_day10.jl -h
usage: soln_day10.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
