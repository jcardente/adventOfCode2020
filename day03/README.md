# Solution to Day 3 Puzzles

The puzzles on day 3 involved moving a toboggan through
a grid of open spaces and trees. The grid is represented
as an ASCII map with `.` designating an open space and
`#` a tree. For example, 

```
..##.......
#...#...#..
.#....#..#.
..#.#...#.#
.#...##..#.
..#.##.....
.#.#.#....#
.#........#
#.##...#...
#...##....#
.#..#...#.#
```

The hieght of the grid is fixed but the width is not, navigating off
the right edge will cause the toboggan to re-enter the grid on the
left edge. Toboggans start at top left and move through the grid in
fixed steps (eg. right 3, down 1) until reaching the bottom.

Each puzzle required counting the number of trees hit along
one (part 1) or multiple (part 2) paths. 

My final solution consisted of a function to convert the ASCII grid into a 
2D boolean matrix

```julia
function makeMap(input)
  ## NB - convert ascii map to a 2D bool array
  vcat(map(x -> x',
           [[c == '.' for c in collect(l)] for l in input])...)
end
```

Storing the slopes in a list of Tuples

```julia
# NB - Tuple is of the form (right, down). Values reordered slopes so
#      that part1 is first
Slopes = [(3,1), (1,1), (5,1), (7,1), (1,2)]
```

And then iterating over the slopes, moving the toboggan through the
grid for each and counting the number of trees hit,

```julia
  if args["part"] == "part1"
    slopes = Slopes[1:1]
  else
    slopes = Slopes
  end

  treeCounts = Int64[]
  for s in slopes
    row, col = (1,1)
    deltaCol = s[1]    
    deltaRow = s[2]
    ntrees   = 0
    while row <= maxRow
      if mapArray[row, col] == false
        # NB - hit a tree!
        ntrees += 1
      end
    
      row += deltaRow
      col += deltaCol

      if col > maxCol
        # NB - Julia uses 1 based indexing
        col = (col % maxCol)
      end
    end

    push!(treeCounts, ntrees)
    @printf("Slope %d:%d hit %d trees!\n", deltaRow, deltaCol, ntrees)
  end
  
  soln = reduce(*, treeCounts)
  @printf("Product of tree counts is %d\n", soln)
```

The final solution can be run from the command line with the following arguments,

```julia
% julia soln_d03.jl --help
usage: soln_d03.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
