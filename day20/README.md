# Day 20 Solutions

[Day 20](https://adventofcode.com/2020/day/20) required figuring how
to arrange a collection of tiles into a larger image and then finding
patterns in that combined image. 

Below is an example of how tiles were specified in the input,

```
Tile 2311:
..##.#..#.
##..#.....
#...##..#.
####.#...#
##.##.###.
##...#.###
.#.#.#..##
..#....#..
###...#.#.
..###..###
```

Tiles were created such that each edge matched the edge of another tile
in the input. The main task was to identify the matching edges and 
figure out how to arrange them into a sqaure. The challenge was that
each tile was randomly flipped and rotated. 

To start, I wrote a function that encoded a string of `.` and `#`
characters as a binary value. This let me create a numeric signature
for each tile edge.

```julia
function encodeString(s)
  i   = 0
  val = 0
  for c in reverse(s)
    if c=='#'
      val |= 1 << i
    end
    i+= 1
  end
  return val
end
```

Next, I created an object to represent a tile and it's data,

```julia
mutable struct Tile
  id::String
  data::Array{String,1}
  left::Int64
  right::Int64
  top::Int64
  bottom::Int64


  function Tile(id::String, data::Array{String,1})
    t      = new()
    t.id   = id
    t.data = data

    # Encode edges as binary numbers
    t.top    = encodeString(first(data))
    t.bottom = encodeString(last(data))
    t.right  = encodeString(join([last(d) for d in data], ""))
    t.left   = encodeString(join([first(d) for d in data], ""))

    return t
  end
end
```

and wrote routines to flip and rotate arrays of ascii strings,

```julia
function dataIdentity(data::Array{String,1})
  data
end

function dataFlipVertical(data::Array{String,1})
  reverse(data)
end

function dataRotateRight(data::Array{String,1})
  [join([data[r][c] for r in length(data):-1:1],"") for c in 1:length(data[1])]
end
```

I then pre-computed the eight possible transformations of each tile,

1. Unchange
2. Rotated right once
3. Rotated right twice
4. Rotated right three times
5. Vertical flipped
6. Vertical flipped, rotated right once
7. Vertical flipped, rotated right twice
8. Vertical flipped, rotated right three times

Next, I created a mapping table between edge values and tiles to make it really
easy to find possible neighbors. 

With that in place, I wrote a dynamic programming solution that:

- Picked a tile for the top left
- Iteratively tried to add tiles left to right, top to bottom
- For each tile position, used the edgme mapping table to find
  candidates that matched the edges of the already place neighbors
  at left and up. 
- If no matchign tiles are found, the algorithm backtracks to the
  next possible solution.
  
I also implemented checks to ensure that once a tile was used, none
of its other 7 variants could be subsequently used.

```julia
function findSolution(tiles::Dict{String,Tile},
                      edges::Dict{Int64,Set{String}},
                      grid::Array{String,2},
                      row::Int64,
                      col::Int64)

  gridSize = size(grid)[1]
  if row > gridSize
    # We found a solution, grid contains answer
    return true
  end

  # Already used tiles
  usedBaseIds = [tileGetBaseId(x) for x in filter(!isempty, vec(grid))]

  # Candidate tiles
  candidates = filter(id -> !(tileGetBaseId(id) in usedBaseIds), keys(tiles))

  # Find candidates that match borders at top and left
  if row > 1
    topEdge    = tiles[grid[row-1,col]].bottom
    candidates = filter(t -> tiles[t].top == topEdge, candidates)
  end

  if col > 1
    leftEdge    = tiles[grid[row,col-1]].right
    candidates = filter(t -> tiles[t].left == leftEdge, candidates)
  end

  # Return false if there are no candidates
  if length(candidates) == 0
    return false
  end

  # Try each candidate in position
  nextrow = row
  nextcol = col + 1
  if nextcol > gridSize
    nextcol = 1
    nextrow += 1
  end

  for c in candidates
    grid[row, col] = c
    rv = findSolution(tiles,
                      edges,
                      grid,
                      nextrow,
                      nextcol)
    if rv == true
      # Found a solution!
      return true
    end
    grid[row,col] = ""
  end

  return false
end
```

For part 2, I simple scanned the combined image looking for `#` characters in the appropriate positions. 
Luckily, I was able to re-use the flipping and rotation routines I wrote for transforming tiles
to also transform the combined picture. 

```julia
monsterWidth  = 20
monsterHeight = 3
monsterCoords = [
  (2, 18)
  (1, 0)
  (1, 5)
  (1, 6)
  (1, 11)
  (1, 12)
  (1, 17)
  (1, 18)
  (1, 19)
  (0, 1)
  (0, 4)
  (0, 7)
  (0, 10)
  (0, 13)
  (0, 16) ]


function findMonsters(picture)
  # Check all positions
  monsterStarts = Tuple{Int64,Int64}[]
  for r in monsterHeight:length(picture)
    for c in 1:(length(picture)-monsterWidth)
      if all([picture[r-mr][c+mc] =='#' for (mr,mc) in monsterCoords])
        push!(monsterStarts, (r,c))
      end
    end
  end

  return monsterStarts
end
```

As usual, the final solution can be run from the command line

```
% julia soln_day20.jl -h
usage: soln_day20.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
