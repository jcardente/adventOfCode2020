# Day 24 Solutions

[Day 24](https://adventofcode.com/2020/day/23) involved flipping tiles in
a hexoganol grid. 

To start, all of the tiles in the hexagonal tile floor were white side
up. The puzzle input was a list of paths to tiles that needed to be
flipped. Each path was a list of directions to step to get to the target tile.
For example, 

```
sesenwnenenewseeswwswswwnenewsewsw
neeenesenwnwwswnenewnwwsewnenwseswesw
seswneswswsenwwnwse
nwnwneseeswswnenewneswwnewseswneseene
swweswneswnenwsewnwneneseenw
```

Where the directions were, 
- `e`: east
- `se`: south east
- `sw`: south west
- `w`: west
- `nw`: north west
- `ne`: north east

In part 1, the goal was to flip the tiles specified in the puzzle input
and then count the number of black tiles. The puzzle sequence was designed
such that some tiles may be flipped more than once. 

I chose to represent the hexagonal tile coordinates using a 
[cube coordinate system](https://www.redblobgames.com/grids/hexagons/#coordinates-cube).
The grid itself was represented as a dictionary indexed by tile coordinates. This
allowed tracking only the tiles necessary to find the solution. 

```juilia
floor = Dict{Tuple{Int64, Int64, Int64}, Int64}()
```

I then wrote a routine to follow a path of directions through
the cube coordinate space,

```julia
function followPath(path)
  # NB - cube coordinate system see
  #
  # https://www.redblobgames.com/grids/hexagons/#coordinates
  x = 0
  y = 0
  z = 0
  for step in pathToSteps(path)
    if step == "e"
      x += 1
      y -= 1
      
    elseif step == "w"
      x -= 1
      y += 1
      
    elseif step == "ne"
      x += 1
      z -= 1
      
    elseif step == "sw"
      x -= 1
      z += 1
      
    elseif step == "nw"
      y += 1
      z -= 1
      
    elseif step == "se"
      y -= 1
      z += 1
      
    else
      error(@sprintf("Unknow step: %s", step))
    end
    
  end
  
  return (x,y,z)
end
```

Finding the solution to part 1 was then a matter of processing each path 
and flipping the designated tiles,

```julia
for p in paths
  coords = followPath(p)
  if !haskey(floor, coords)
    # default is white (0)
    floor[coords] = 0
  end

  # flip tile
  floor[coords] = floor[coords] == 0 ? 1 : 0
end
  
numBlack = sum(values(floor))
@printf("Part 1: number of black tiles: %d\n", numBlack)
```

Part 2 extended the problem by turning it into a game of life. After the initial
tiles were flipped in part 1, the floor was updated using the following rules

- Any black tile with 0 or >2 black tile neighbors is flipped to white
- Any white tile with 2 black tile neighbors is flipped to black.

Solving part 2 was simply a matter of inspecting neighbors and updating
tile states. The only subtle trick was to make sure that the neighbor
of any tile flipped to black is initialized in the sparse floor structure
so that it's state could be checked.

```julia
NeighborCoords =  [
    (+1, -1, 0), (+1, 0, -1), (0, +1, -1), 
    (-1, +1, 0), (-1, 0, +1), (0, -1, +1)
]


function getNeighbors(floor::Dict{Tuple{Int64, Int64, Int64}, Int64},
                      coord::Tuple{Int64, Int64, Int64})
  values = Bool[]
  for n in NeighborCoords
    x = coord[1] + n[1]
    y = coord[2] + n[2]
    z = coord[3] + n[3]
    c= (x,y,z)
    if haskey(floor, c)
      push!(values, floor[c])
    end
  end
  
  return values
end


function fillNeighbors!(floor::Dict{Tuple{Int64, Int64, Int64}, Int64},
                        coord::Tuple{Int64, Int64, Int64})
  for n in NeighborCoords
    x = coord[1] + n[1]
    y = coord[2] + n[2]
    z = coord[3] + n[3]
    c= (x,y,z)
    if !haskey(floor, c)
      floor[c] = 0
    end
  end
end


function simulateDay!(floor::Dict{Tuple{Int64, Int64, Int64}, Int64})

  # Make sure neighbors of all black tiles exist in case they need to
  # be flipped
  for (coord, color) in floor
    if color == 1
      fillNeighbors!(floor, coord)
    end
  end

  # Make a list of tiles to flip
  toFlip  = Tuple{Int64, Int64, Int64}[]
  for (coord, color) in floor
    ncount = sum(getNeighbors(floor, coord))

    if (color == 1) && ((ncount == 0) || (ncount > 2))
      push!(toFlip, coord)
      
    elseif (color == 0) && (ncount == 2)
      push!(toFlip, coord)

    end
  end

  for c in toFlip
    if floor[c] == 1
      floor[c] = 0
    else
      floor[c] = 1
    end
  end
end
```

Final solution can be run from the command line,

```
% julia soln_day24.jl -h
usage: soln_day24.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
