# Day 16 Solutions

For [day 16](https://adventofcode.com/2020/day/16), the task was to 
match train ticket values with field labels based on provided rules. 

The puzzle input was as follows,

```
class: 1-3 or 5-7
row: 6-11 or 33-44
seat: 13-40 or 45-50

your ticket:
7,1,14

nearby tickets:
7,3,47
40,4,50
55,2,20
38,6,12
```


The first section specifies the rules for each field, specifically the
valid range values. The second section provides the values for your
ticket. The last section similarly provides values for other passenger
tickets. In both cases, the ticket values are listed in the same order
according to field.  However, that order is uknown and determining it
was the puzzle's goal.

I used a Julia composite type (eg. object) to store the field rules and wrote a
simple function that checked if a value satified a rule's criteria,

```julia
struct TicketRule
  name::String
  range1::Tuple{Int64, Int64}
  range2::Tuple{Int64, Int64}
end

function ruleCheck(r::TicketRule, v::Int)
  ((r.range1[1] <= v && v <= r.range1[2]) ||
   (r.range2[1] <= v && v <= r.range2[2]))
end
```

The tickets were represented as integer arrays. 

Part 1 asked to identify invalid field values that did not
satisfy any of the provided rules. I solved this
by,

1. Iterating over each ticket value
2. Testing it against each rule using a list comprehension
3. Filtering out values that satisfied one or more rules (eg. valid values)

```julia
fieldvalues = collect(Iterators.flatten(nearbyTickets))
badvalues   = filter((v) -> !any([ruleCheck(r,v) for r in rules]),
                     fieldvalues)
```

For part 2, the task was to determine the mapping between fields and
ticket value positions. The main challenge was that nearly all of the
ticket value positions satisfied multiple rules.

The first step was to discard invalid tickets,

```julia
goodTickets = filter(
  t -> all([any([ruleCheck(r,v) for r in rules]) for v in t]),
  nearbyTickets)
```

Next, I determined the rules satisfied by each ticket value position across all of the
tickets,

```julia
maybeRuleIdxs = Dict{String, Set{Int64}}()
idxsToCheck = [i for i in 1:length(goodTickets[1])]
for r in rules
  maybeRuleIdxs[r.name] = Set{Int64}()
  for idx in idxsToCheck
    if all([ruleCheck(r,t[idx]) for t in goodTickets])
      push!(maybeRuleIdxs[r.name], idx)
    end
  end
end
```

Examining the results showed that,

- Each rule's possible indexes was a superset of another
  rule with one additional index
- There was one rule with only one possible index

Finding the correct mapping was then a matter of,

1. Sorting the ticket value positions by the number of rules they satisfied
2. Looping over the ticket value positions in ascending order and
    - Eliminating already assigned rules from the candidate list
    - Assigning the remaining rule to this position

The code for this was,

```julia
ruleIdxs = Dict{String, Int64}()
ruleOrder = [i[1] for i in
             sort([(k, length(v)) for (k,v) in pairs(maybeRuleIdxs)],
                 by= x -> x[2])]

assignedIdxs = Set{Int64}()
for r in ruleOrder
  available = setdiff(maybeRuleIdxs[r], assignedIdxs)
  
  idx = first(available)
  push!(assignedIdxs, idx)
  ruleIdxs[r] = idx
end
```

As usual, the final solution can be run from the command line, 

```
% julia soln_day16.jl -h
usage: soln_day16.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
