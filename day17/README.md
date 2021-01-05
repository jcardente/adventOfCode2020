# Day 17 Solutions

[Day 17](https://adventofcode.com/2020/day/17) was more fun with Conway's Game of Life, 
this time in higher dimensions. Both parts of the puzzle involved simulating an infinite
grid of "Conway Cubes" that change state based on the states of their immediate
neighbors. In part 1, the grid is 3D. In part 2, it is 4D. 

The puzzle input was a flat plane of initial cube states, for example,

```
.#.
..#
###
```

where a `#` symbol represented an active cube. All other cubes in the inifite
grid were, by default, inactive.

In each iteration of the simulation, the cubes updated their state
according to the following nodes,

- If a cube is active and exactly 2 or 3 of its neighbors are also
  active, the cube remains active. Otherwise, the cube becomes
  inactive.
- If a cube is inactive but exactly 3 of its neighbors are active, the
  cube becomes active. Otherwise, the cube remains inactive.

The update rules stayed the same in both parts of the puzzle. One difference
was the number of neighbors, 26 in part 1 and 80 in part 2. 

After solving part 1, I refactored my code so that it could simulate both
3D and 4D grids. 

I created a Julia composite type to store the state of the grid,

```julia
mutable struct Grid
  numdim::Int64
  maxdim::Int64
  grid::Dict{Tuple{Int64, Int64, Int64, Int64}, Int64}
end

Grid(numdim) = Grid(numdim, 0,Dict{Tuple{Int64, Int64, Int64, Int64}, Int64}())
```

Each cube was represented as an item in a dictionary keyed by a coordinate tuple. This
allowed keeping a sparse representation of the grid and only tracking cubes of potential
interest. 

I next wrote two helper routines to get and set cube state,

```julia
function getCubeState(grid::Grid, x::Int64, y::Int64, z::Int64, w::Int64)
  coords = (x, y, z, w)
  state = 0
  if haskey(grid.grid, coords)
    state = grid.grid[coords]
  end

  return state
end

  
function updateCubeState(grid::Grid, x::Int64, y::Int64, z::Int64, w::Int64, state::Int64)
  coords = (x, y, z, w)
  grid.grid[coords] = state

  maxcoord = max(x,y,z, w)
  if ((state == 1) && (abs(maxcoord) >= grid.maxdim))
    grid.maxdim = maxcoord + 1
  end
end
```

One thing to note is that anytime a cube was activated, the size of the grid
was expaneded so that it's neighbors would be considered in future simulation
steps. 

I also wrote a routine to get a cube's neighbor states,

```julia
function getActiveNeighborCount(grid::Grid, x::Int64, y::Int64, z::Int64, w::Int64)
  ncount = 0

  if (grid.numdim == 4)
    wrange = (w-1):(w+1)
  else
    wrange = 0:0
  end
  
  for nw in wrange
    for nz in (z-1):(z+1)
      for ny in (y-1):(y+1)
        for nx in (x-1):(x+1)
          if ((nz!=z) || (ny!=y) || (nx!=x) || (nw!=w))
            ncount += getCubeState(grid, nx, ny, nz, nw)
          end
        end
      end  
    end
  end
  
  return ncount
end
```

While solving part 1, the code essentially ignored the fourth dimension. 

Finally, I wrote routine to update the grid state, again ignoring the fourth dimension when solving
part 1,

```julia
function updateGrid!(grid)
  idxrange = (-1*(grid.maxdim)):(grid.maxdim)

  if (grid.numdim == 4)
    wrange = idxrange
  else
    wrange = 0:0
  end
  
  nextgrid = deepcopy(grid)
  for w in wrange
    for z in idxrange
      for y in idxrange
        for x in idxrange
          ncount = getActiveNeighborCount(grid, x, y, z, w)
          state  = getCubeState(grid, x, y, z, w)

          if ((state==1) &&
              (ncount !=2) &&
              (ncount !=3))
            updateCubeState(nextgrid, x, y, z, w, 0)
          
          elseif ((state==0) && (ncount==3))
            updateCubeState(nextgrid, x, y, z, w, 1)
            
          end  
        end
      end
    end
  end
  
  grid.grid   = nextgrid.grid
  grid.maxdim = nextgrid.maxdim
end
```

With all that in place, solving each part was simply a matter of initializing
the grid with the appropriate number of dimensions,

```julia
if (args["part"] == "part1")
  grid  = gridInit(3, lines);

  for i in 1:6
    updateGrid!(grid);
  end
  @printf("Part 1 Active Cubes: %d\n", countActiveCubes(grid))

else
  grid  = gridInit(4, lines);

  for i in 1:6
    updateGrid!(grid);
  end
  @printf("Part 2 Active Cubes: %d\n", countActiveCubes(grid))
    
end
```

As usual, the final solution can be run from the command line,

```
% julia soln_day17.jl -h
usage: soln_day17.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
