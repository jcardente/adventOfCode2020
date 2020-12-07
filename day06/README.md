# Solution to Day 6 Puzzles

Day 6 involves counting the number of "customs declaration form"
questions each group of travelers answers `yes` to. In part 1, 
the task is to count the number of questions answered `yes` by
**anyone** in a group. For part2, you're instead asked to count
the questions answered `yes` by **everyone** in a group.

The forms have 26 questions represented by the characters 
`a-z`. Individual responses are encoded as an ASCII string where
the presence of a character means the question was answered
`yes`. Each group is represented as consecutive lines in the
data provided. Groups are separated by blank lines. 

I re-used code from the day02 solution to combine each group's
responses into a single string with individual form respones
separated by a space.

I then wrote a function to convert each group string
into a list of sets. 

```julia
function convertGroupsToSets(groups)
  groupSets = Array{Array{Set{Char},1},1}()
  for group in groups
    groupSet = [Set(collect(f)) for f in split(group, " ")]
    push!(groupSets, groupSet)
  end
  return groupSets
end
```

Representing groups in this way allowed answering parts 1 and
2 by simply combing the sets using either union or intersection
operations,

```julia
if args["part"] == "part1"
  mergefn = union
else
  mergefn = intersect
end
groupsMerged = [reduce(mergefn, gset) for gset in groupSets]
```

Then it was simply a matter of summing the lengths of each 
merged group set,

```julia
yesCounts = Int64[]
for group in groupsMerged
  push!(yesCounts, length(group))
end
@printf("Sum of YES responses is: %d\n", sum(yesCounts))
```

Final solution can be run with the following arguments,

```
% julia soln_day06.jl --help
usage: soln_day06.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
