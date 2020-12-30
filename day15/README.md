# Day 15 Solutions

[Day 15](https://adventofcode.com/2020/day/15) involved simulating a memory game. After an 
initial list of seed numbers, the game proceeds as follows.

- If the last number was spoken for the first time, the player says 0.
- Otherwise, the player says how many turns ago the time was last spoken. 

The only difference between parts 1 and 2 was the number of games turns to simulate.

I solved this by using a dictionary to store the last turn each number was spoken. 
After initializing it using the input numbers,

```julia
tracker = Dict{Int64, Int64}()
age     = 1
for n in numbers[1:end-1]
  tracker[n] = age
  age += 1
end
lastn   = last(numbers)
```

It was fairly simple to simulate the game play

```julia
while age < endage
  if haskey(tracker, lastn)
    nextn = age - tracker[lastn]
  else
    nextn = 0
  end
    
  tracker[lastn] = age
  lastn = nextn;
  age += 1;
end
@printf("Age: %d, Say: %d\n", age, lastn) 
```

This solution was efficient enough that no changes were needed to solve part 2.

The final solution can be run from the command line,

```
% julia soln_day15.jl -h
usage: soln_day15.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
