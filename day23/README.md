# Day 23 Solutions

[Day 23](https://adventofcode.com/2020/day/23) involved another game
with moving cups. 

The game started with a sequence of cups arranged in a clockwise
circle. Each cup was represented by an integer and the circle as a
list of cup labels. The first cup was designated as the "current
cup". The game proceeded in rounds according to the following rules.

- The three cups immediately clockwise of the current cup
  are removed from the circle.
- The cup with the next lowest label still in the circle, wrapping to
  the highest cup label if necessary, is selected as the destination
  cup.
- The removed cups are inserted into the circle immediately clockwise
  to the destination cup.
  
In both parts, a number of rounds were played and the solutions were
based on the cups labels in specific positions. In part 1, there were
9 cups and 100 rounds. In part 2, there were one million cups and ten
million rounds!

The game itself was simple to simulate. The challenge was getting
part 2 to run efficiently. My initial solution relied on Julia
array slicing to remove and insert the cups. This was fine for
part 1 but horribly slow for part 2.

The final solution was to represent the circle as a pre-allocated
array of integers in which the value stored at each index was the
label for the next cup in the sequence. This made removing and
re-inserting the cups a simple matter of updating three array values.

```julia
circle[currCup]        = circle[last(cupsTake)]
circle[last(cupsTake)] = circle[destCup]
circle[destCup]        = first(cupsTake)
```

To find the cups to remove, I started with the current cup
and used the array to "walk" the list,

```julia
cupsTake = Int64[]
c = currCup
for i in 1:3
  push!(cupsTake, circle[c])
  c = circle[c]
end
```

The destination cup was found using a simple loop

```julia
destCup = currCup
while true
  destCup -= 1
  if destCup < 1
    destCup = maxCup
  end
 if !(destCup in cupsTake)
    break
  end
end
```

The final solution can be run from the command line,

```
% julia soln_day23.jl -h
usage: soln_day23.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
