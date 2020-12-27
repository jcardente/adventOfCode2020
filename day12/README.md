# Day 12 Solutions

[Day 12](https://adventofcode.com/2020/day/12) required simulating ferry navigation
instructions to determine the final end point. 

The ferry started off facing in a known direction and the puzzle input was a series
of navigation instructions such as,

```
F10
N3
F7
R90
F11
```

where,
- `F10` would move the ship 10 units east (because the ship starts by
  facing east) to east 10, north 0.
- `N3` would move the ship 3 units north to east 10, north 3.
- `F7` would move the ship another 7 units east (because the ship is
  still facing east) to east 17, north 3.
- `R90` would cause the ship to turn right by 90 degrees and face
  south; it remains at east 17, north 3.
- `F11` would move the ship 11 units south to east 17, south 8.

In the final solution, I used a ship object to encapsulate all of the required
information. 

```julia
mutable struct Ship
  posx::Int64
  posy::Int64
  wayx::Int64
  wayy::Int64
end
```

For part 1, the navigation commands indicated the ship's movements.
In this case, the object's `wayx` and `wayy` fields held the ship's current
direction for the `F` commands.

I then wrote the following routine to update the ship's location for part 1,

```julia
function shipMovePart1!(ship::Ship, dir::Char, amount::Int64)

  if dir=='N'
    ship.posy += amount
    
  elseif dir=='S'
    ship.posy -= amount
    
  elseif dir=='E'
    ship.posx += amount
    
  elseif dir=='W'
    ship.posx -= amount

  elseif dir=='F'
    ship.posx += amount * ship.wayx
    ship.posy += amount * ship.wayy

  elseif (dir=='R' || dir=='L')
    wv   = [ship.wayx ship.wayy]
    rm   = dir == 'L' ? [0 1; -1 0] : [0 -1; 1 0]
    rots = Int(amount / 90)

    wv = wv * rm^rots
    ship.wayx = wv[1]
    ship.wayy = wv[2]
    
  else
    error("Unknown direction")
  end
end
```

For the `R` and `L` commands, rotation matrices were used to move the
waypoint around as necessary.

In part 2, the naviation commands idicated the waypoint's movements. My solution
was nearly identical to that for part 1 except now the `N`, `S`, `E`, and `W` 
commands changed the waypoint's location,

```julia
function shipMovePart2!(ship::Ship, dir::Char, amount::Int64)

  if dir=='N'
    ship.wayy += amount
    
  elseif dir=='S'
    ship.wayy -= amount
    
  elseif dir=='E'
    ship.wayx += amount
    
  elseif dir=='W'
    ship.wayx -= amount

  elseif dir=='F'
    ship.posx += amount * ship.wayx
    ship.posy += amount * ship.wayy

  elseif (dir=='R' || dir=='L')
    wv   = [ship.wayx ship.wayy]
    rm   = dir == 'L' ? [0 1; -1 0] : [0 -1; 1 0]
    rots = Int(amount / 90)

    wv = wv * rm^rots
    ship.wayx = wv[1]
    ship.wayy = wv[2]
    
  else
    error("Unknown direction")
  end
end
```

The final solution can be run from the command line to solve either part,

```
% julia soln_day12.jl -h
usage: soln_day12.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
