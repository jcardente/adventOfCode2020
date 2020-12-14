# ------------------------------------------------------------
# Solution to Advent of Code 2020 Puzzle Day 12
#
# PUZZLE:
#
# --- Day 12: Rain Risk ---
# 
# Your ferry made decent progress toward the island, but the storm
# came in faster than anyone expected. The ferry needs to take evasive
# actions!
# 
# Unfortunately, the ship's navigation computer seems to be
# malfunctioning; rather than giving a route directly to safety, it
# produced extremely circuitous instructions. When the captain uses
# the PA system to ask if anyone can help, you quickly volunteer.
# 
# The navigation instructions (your puzzle input) consists of a
# sequence of single-character actions paired with integer input
# values. After staring at them for a few minutes, you work out what
# they probably mean:
# 
# Action N means to move north by the given value.
# Action S means to move south by the given value.
# Action E means to move east by the given value.
# Action W means to move west by the given value.
# Action L means to turn left the given number of degrees.
# Action R means to turn right the given number of degrees.
# Action F means to move forward by the given value in the direction the ship is currently facing.
# 
# The ship starts by facing east. Only the L and R actions change the
# direction the ship is facing. (That is, if the ship is facing east
# and the next instruction is N10, the ship would move north 10 units,
# but would still move east if the following action were F.)
# 
# F10
# N3
# F7
# R90
# F11
# 
# These instructions would be handled as follows:
# 
# F10 would move the ship 10 units east (because the ship starts by facing east) to east 10, north 0.
# N3 would move the ship 3 units north to east 10, north 3.
# F7 would move the ship another 7 units east (because the ship is still facing east) to east 17, north 3.
# R90 would cause the ship to turn right by 90 degrees and face south; it remains at east 17, north 3.
# F11 would move the ship 11 units south to east 17, south 8.
# 
# At the end of these instructions, the ship's Manhattan distance (sum
# of the absolute values of its east/west position and its north/south
# position) from its starting position is 17 + 8 = 25.
# 
# Figure out where the navigation instructions lead. What is the
# Manhattan distance between that location and the ship's starting
# position?

using Printf
using ArgParse


function inputLoad(fname)
  lines = readlines(fname)
  moves = Tuple{Char, Int64}[]
  for l in lines
    push!(moves, (l[1], parse(Int64, l[2:end])))
  end
  
  return moves
end


mutable struct Ship
  posx::Int64
  posy::Int64
  wayx::Int64
  wayy::Int64
end


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


function parseCommandLine()
  s = ArgParseSettings()
  @add_arg_table s begin
    "input"
      help = "Input file"
      required = true
    "part"
      help = "Part to solve, part1 or part2"
      required = true
  end

  return parse_args(s)
end


function main()  
  args  = parseCommandLine()  
  moves = inputLoad(args["input"]);

  if args["part"] == "part1"
    ship = Ship(0,0,1,0);
    for move in moves
      shipMovePart1!(ship, move[1], move[2]);
    end
    
  else
    ship = Ship(0,0,10,1);
    for move in moves
      shipMovePart2!(ship, move[1], move[2]);
    end
    
  end    

  manDist = sum(abs.([ship.posx, ship.posy]));
  @printf("Ship manhatten distance: %d\n", manDist)
end

main()
