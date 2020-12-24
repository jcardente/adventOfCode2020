# ------------------------------------------------------------
# Solution to Advent of Code 2020 Puzzle Day 24
#
# PUZZLE:
#
# --- Day 24: Lobby Layout ---
# 
# Your raft makes it to the tropical island; it turns out that the
# small crab was an excellent navigator. You make your way to the
# resort.
# 
# As you enter the lobby, you discover a small problem: the floor is
# being renovated. You can't even reach the check-in desk until
# they've finished installing the new tile floor.
# 
# The tiles are all hexagonal; they need to be arranged in a hex grid
# with a very specific color pattern. Not in the mood to wait, you
# offer to help figure out the pattern.
# 
# The tiles are all white on one side and black on the other. They
# start with the white side facing up. The lobby is large enough to
# fit whatever pattern might need to appear there.
# 
# A member of the renovation crew gives you a list of the tiles that
# need to be flipped over (your puzzle input). Each line in the list
# identifies a single tile that needs to be flipped by giving a series
# of steps starting from a reference tile in the very center of the
# room. (Every line starts from the same reference tile.)
# 
# Because the tiles are hexagonal, every tile has six neighbors: east,
# southeast, southwest, west, northwest, and northeast. These
# directions are given in your list, respectively, as e, se, sw, w,
# nw, and ne. A tile is identified by a series of these directions
# with no delimiters; for example, esenee identifies the tile you land
# on if you start at the reference tile and then move one tile east,
# one tile southeast, one tile northeast, and one tile east.
# 
# Each time a tile is identified, it flips from white to black or from
# black to white. Tiles might be flipped more than once. For example,
# a line like esew flips a tile immediately adjacent to the reference
# tile, and a line like nwwswee flips the reference tile itself.
# 
# Here is a larger example:
# 
# sesenwnenenewseeswwswswwnenewsewsw
# neeenesenwnwwswnenewnwwsewnenwseswesw
# seswneswswsenwwnwse
# nwnwneseeswswnenewneswwnewseswneseene
# swweswneswnenwsewnwneneseenw
# eesenwseswswnenwswnwnwsewwnwsene
# sewnenenenesenwsewnenwwwse
# wenwwweseeeweswwwnwwe
# wsweesenenewnwwnwsenewsenwwsesesenwne
# neeswseenwwswnwswswnw
# nenwswwsewswnenenewsenwsenwnesesenew
# enewnwewneswsewnwswenweswnenwsenwsw
# sweneswneswneneenwnewenewwneswswnese
# swwesenesewenwneswnwwneseswwne
# enesenwswwswneneswsenwnewswseenwsese
# wnwnesenesenenwwnenwsewesewsesesew
# nenewswnwewswnenesenwnesewesw
# eneswnwswnwsenenwnwnwwseeswneewsenese
# neswnwewnwnwseenwseesewsenwsweewe
# wseweeenwnesenwwwswnew
# 
# In the above example, 10 tiles are flipped once (to black), and 5
# more are flipped twice (to black, then back to white). After all of
# these instructions have been followed, a total of 10 tiles are
# black.
# 
# Go through the renovation crew's list and determine which tiles they
# need to flip. After all of the instructions have been followed, how
# many tiles are left with the black side up?
#
# --- Part Two ---
# 
# The tile floor in the lobby is meant to be a living art
# exhibit. Every day, the tiles are all flipped according to the
# following rules:
# 
# - Any black tile with zero or more than 2 black tiles immediately
#   adjacent to it is flipped to white.
#
# - Any white tile with exactly 2 black tiles immediately adjacent to
#   it is flipped to black.
#
# Here, tiles immediately adjacent means the six tiles directly
# touching the tile in question.
# 
# The rules are applied simultaneously to every tile; put another way,
# it is first determined which tiles need to be flipped, then they are
# all flipped at the same time.
# 
# In the above example, the number of black tiles that are facing up
# after the given number of days has passed is as follows:
# 
# Day 1: 15
# Day 2: 12
# Day 3: 25
# Day 4: 14
# Day 5: 23
# Day 6: 28
# Day 7: 41
# Day 8: 37
# Day 9: 49
# Day 10: 37
# 
# Day 20: 132
# Day 30: 259
# Day 40: 406
# Day 50: 566
# Day 60: 788
# Day 70: 1106
# Day 80: 1373
# Day 90: 1844
# Day 100: 2208
# 
# After executing this process a total of 100 times, there would be 2208 black tiles facing up.
# 
# How many tiles will be black after 100 days?


using Printf
using ArgParse


function inputLoad(fname)
  lines = readlines(fname)
end

function pathToSteps(path)
  steps = String[]
  idx   = 1
  while idx <= length(path)

    l = 0
    if path[idx] in ['e','w'] 
      l = 0
    else
      # Must be ne, nw, se, sw
      l = 1
    end

    push!(steps, path[(idx):(idx+l)])
    idx += l+1
  end

  return steps
end


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
  args = parseCommandLine()  

  paths = inputLoad(args["input"])
  floor = Dict{Tuple{Int64, Int64, Int64}, Int64}()

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

  if args["part"] == "part1"
    exit()
  end
  
  for i in 1:100
    simulateDay!(floor)
    numBlack = sum(values(floor))
    @printf("Day %d: %d\n", i, numBlack)
  end
end

main()
