# Solution to Day 7 Puzzle

Day 7 was fun with nested bags. The input was a set of rules
like the following,

```
- light red bags contain 1 bright white bag, 2 muted yellow bags.
- dark orange bags contain 3 bright white bags, 4 muted yellow bags.
- bright white bags contain 1 shiny gold bag.
- muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.
- shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.
- dark olive bags contain 3 faded blue bags, 4 dotted black bags.
- vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.
- faded blue bags contain no other bags.
- dotted black bags contain no other bags.
```

In part 1, the task was to calculate the number of bags that
could contain at least one `shiny gold bag`; 4 in the example
above. In part 2, the task was to calculate the number of bags
that a `shiny gold bag` must contain. 

Both puzzles essentially involved traversing a tree of bags. To start,
I created a composite type (Julia's version of objects) and constructor that
only required a name.

```julia
mutable struct Bag
  name::String
  contents::Dict{String, Int64}
  parents::Set{String}
end

Bag(name::String) = Bag(name, Dict{String,Int64}(), Set{String}())
```

Next, I wrote methods to add contents and parents,

```julia
function addContents(bag::Bag, name::String, count::Int64)
  if haskey(bag.contents, name)
    error("Bag already has contents named " * name)
  end
  bag.contents[name] = count
end


function addParent(bag::Bag, parent::String)
  push!(bag.parents, parent)
end
```

I then wrote a function that,

- processed the string rules
- created Bag objects for each encountered
- stored all Bag objects in a dictionary keyed by bag name

That dictionary essentially encoded the tree and made it traversable by 
bag name. Although I could have used object pointers to create the
tree, names proved handy for part 1 as multiple parent paths had
common ancestors.

The solution to part 1 used an algorithm similar in spirit to 
Dijkstra's for finding the shortest path in a graph. It maintained
a list of candidates that represented the frontier in the graph.
A list of discovered parents was used to avoid repeating any paths.
Iteration stops when there are no more candidates.

```julia
function findAllParents(bagsDict, bagname)
  parents    = Set{String}()
  candidates = bagsDict[bagname].parents
  while length(candidates) > 0
    nextCandidates = Set{String}()
    for c in candidates
      if !(c in parents)
        push!(parents, c)
        union!(nextCandidates, bagsDict[c].parents)
      end
    candidates = nextCandidates
    end
  end    
  return [p for p in parents]
end
```

The solution for part two required traversing the graph in the opposite
direction, finding the leafs, and carefully counting the bags contained
on the way back up the graph,

```julia
function countAllChildren(bagsDict, bagname)
  bag = bagsDict[bagname]
  if length(bag.contents) == 0
    return 0
  end

  # NB - count the bags contained and then
  #      sum number of bags they contain!
  nchildren   = sum(values(bag.contents))
  childCounts = [countAllChildren(bagsDict, n)*v for (n,v) in bag.contents]
  
  return nchildren + sum(childCounts)
end
```

Final solution can be run from the command line using the following arguments

```
% julia soln_day07.jl --help
usage: soln_day07.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
