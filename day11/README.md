# Day 11 Solutions

[Day 11](https://adventofcode.com/2020/day/11) involved
modeling passenger seat selections on a ferry using rules
similar to Conway's [Game of Life](https://en.wikipedia.org/wiki/Conway%27s_Game_of_Life).

The puzzle input was an ASCII map of available seats where `L` represents
a seat and `.` a floor tile.

```
L.LL.LL.LL
LLLLLLL.LL
L.L.L..L..
LLLL.LL.LL
L.LL.LL.LL
L.LLLLL.LL
..L.L.....
LLLLLLLLLL
L.LLLLLL.L
L.LLLLL.LL
```

For part 1, the passenger seat selection rules were

- If a seat is empty (L) and there are no occupied seats adjacent to
  it, the seat becomes occupied.
- If a seat is occupied (#) and four or more seats adjacent to it are
  also occupied, the seat becomes empty.
- Otherwise, the seat's state does not change.
- Floor (.) never changes; seats don't move, and nobody sits on the
  floor.

The seat map was designed such that the passenger seat choices stabilized
after a a number of iterations.

I wrote a routine to convert the input into a 2D array of characters,

```julia
function seatmapCreate(lines)
  nrow = length(lines)
  ncol = length(lines[1])

  seatmap = fill('.',nrow+2, ncol+2)
  seatmap[2:nrow+1,2:ncol+1] = permutedims(hcat([collect(l) for l in lines]...))

  return seatmap
end
```

another routine to update the seat choices,

```julia
function seatmapUpdatePart1(seatmap)
  newSeatmap = copy(seatmap)
  nrow, ncol = size(seatmap)

  neighborIdxs = [(-1,-1), (-1,0), (-1,1),
                  (0,-1),          (0,1),
                  (1,-1),  (1,0,), (1,1)]
  
  for i = 2:(nrow-1), j=2:(ncol-1)
    if seatmap[i,j] != '.'
      neighbors = [seatmap[i+x[1],j+x[2]] for x in neighborIdxs]
      noccupied = sum([c=='#' for c in neighbors])

      if ((seatmap[i,j] == 'L') && (noccupied==0))
        newSeatmap[i,j] = '#'
      elseif ((seatmap[i,j] == '#') && (noccupied >= 4))
        newSeatmap[i,j] = 'L'
      end
    end
  end
  
  return newSeatmap
end
```

and a main simulation loop that iterated until the seat map stabilized,

```julia
  iters = 0
  while true
    if (args["part"] == "part1")
      newSeatmap = seatmapUpdatePart1(seatmap);
    else
      newSeatmap = seatmapUpdatePart2(seatmap);
    end
    
    if (newSeatmap == seatmap)
      break
    end

    seatmap = newSeatmap
    iters += 1
  end

  noccupied = sum(seatmap .== '#')
  @printf("Number of occupied seats: %d\n", noccupied)
```


For part 2, instead of simply looking at immediate neighbors, the update rules now required
finding the first occupied or unoccupied in each of the eight directions - basically simple 
ray casting. This was done by adding an inner loop to the routine from part 1 that explored
each direction in turn,

```julia
function seatmapUpdatePart2(seatmap)
  newSeatmap = copy(seatmap)
  nrow, ncol = size(seatmap)

  neighborSlopes = [(-1,-1), (-1,0), (-1,1),
                    (0,-1),          (0,1),
                    (1,-1),  (1,0,), (1,1)]
  
  for i = 2:(nrow-1), j=2:(ncol-1)
    if seatmap[i,j] != '.'
    
      neighbors = Char[]
      for slope in neighborSlopes
        di = i + slope[1]
        dj = j + slope[2]
        while ((di > 1) && (di < nrow) &&
               (dj > 1) && (dj < ncol))
          if seatmap[di,dj] in ['#','L']
            push!(neighbors, seatmap[di,dj])
            break
          end
          di += slope[1]
          dj += slope[2]
        end
      end
      
      noccupied = sum([c=='#' for c in neighbors])
      if ((seatmap[i,j] == 'L') && (noccupied==0))
        newSeatmap[i,j] = '#'
      elseif ((seatmap[i,j] == '#') && (noccupied >= 5))
        newSeatmap[i,j] = 'L'
      end
    end
  end
  
  return newSeatmap
end
```

Final solution can be run from the command line to solve either part,

```
% julia soln_day11.jl -h
usage: soln_day11.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
