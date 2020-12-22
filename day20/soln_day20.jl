# ------------------------------------------------------------
# Solution to Advent of Code 2020 Puzzle Day 20
#
# PUZZLE:
#
# --- Day 20: Jurassic Jigsaw ---
#
# The high-speed train leaves the forest and quickly carries you
# south. You can even see a desert in the distance! Since you have
# some spare time, you might as well see if there was anything
# interesting in the image the Mythical Information Bureau satellite
# captured.
#
# After decoding the satellite messages, you discover that the data
# actually contains many small images created by the satellite's
# camera array. The camera array consists of many cameras; rather than
# produce a single square image, they produce many smaller square
# image tiles that need to be reassembled back into a single image.
#
# Each camera in the camera array returns a single monochrome image
# tile with a random unique ID number. The tiles (your puzzle input)
# arrived in a random order.
#
# Worse yet, the camera array appears to be malfunctioning: each image
# tile has been rotated and flipped to a random orientation. Your
# first task is to reassemble the original image by orienting the
# tiles so they fit together.
#
# To show how the tiles should be reassembled, each tile's image data
# includes a border that should line up exactly with its adjacent
# tiles. All tiles have this border, and the border lines up exactly
# when the tiles are both oriented correctly. Tiles at the edge of the
# image also have this border, but the outermost edges won't line up
# with any other tiles.
#
# For example, suppose you have the following nine tiles:
#
# Tile 2311:
# ..##.#..#.
# ##..#.....
# #...##..#.
# ####.#...#
# ##.##.###.
# ##...#.###
# .#.#.#..##
# ..#....#..
# ###...#.#.
# ..###..###
#
# Tile 1951:
# #.##...##.
# #.####...#
# .....#..##
# #...######
# .##.#....#
# .###.#####
# ###.##.##.
# .###....#.
# ..#.#..#.#
# #...##.#..
#
# Tile 1171:
# ####...##.
# #..##.#..#
# ##.#..#.#.
# .###.####.
# ..###.####
# .##....##.
# .#...####.
# #.##.####.
# ####..#...
# .....##...
#
# Tile 1427:
# ###.##.#..
# .#..#.##..
# .#.##.#..#
# #.#.#.##.#
# ....#...##
# ...##..##.
# ...#.#####
# .#.####.#.
# ..#..###.#
# ..##.#..#.
#
# Tile 1489:
# ##.#.#....
# ..##...#..
# .##..##...
# ..#...#...
# #####...#.
# #..#.#.#.#
# ...#.#.#..
# ##.#...##.
# ..##.##.##
# ###.##.#..
#
# Tile 2473:
# #....####.
# #..#.##...
# #.##..#...
# ######.#.#
# .#...#.#.#
# .#########
# .###.#..#.
# ########.#
# ##...##.#.
# ..###.#.#.
#
# Tile 2971:
# ..#.#....#
# #...###...
# #.#.###...
# ##.##..#..
# .#####..##
# .#..####.#
# #..#.#..#.
# ..####.###
# ..#.#.###.
# ...#.#.#.#
#
# Tile 2729:
# ...#.#.#.#
# ####.#....
# ..#.#.....
# ....#..#.#
# .##..##.#.
# .#.####...
# ####.#.#..
# ##.####...
# ##..#.##..
# #.##...##.
#
# Tile 3079:
# #.#.#####.
# .#..######
# ..#.......
# ######....
# ####.#..#.
# .#...#.##.
# #.#####.##
# ..#.###...
# ..#.......
# ..#.###...
#
# By rotating, flipping, and rearranging them, you can find a square
# arrangement that causes all adjacent borders to line up:
#
# #...##.#.. ..###..### #.#.#####.
# ..#.#..#.# ###...#.#. .#..######
# .###....#. ..#....#.. ..#.......
# ###.##.##. .#.#.#..## ######....
# .###.##### ##...#.### ####.#..#.
# .##.#....# ##.##.###. .#...#.##.
# #...###### ####.#...# #.#####.##
# .....#..## #...##..#. ..#.###...
# #.####...# ##..#..... ..#.......
# #.##...##. ..##.#..#. ..#.###...
#
# #.##...##. ..##.#..#. ..#.###...
# ##..#.##.. ..#..###.# ##.##....#
# ##.####... .#.####.#. ..#.###..#
# ####.#.#.. ...#.##### ###.#..###
# .#.####... ...##..##. .######.##
# .##..##.#. ....#...## #.#.#.#...
# ....#..#.# #.#.#.##.# #.###.###.
# ..#.#..... .#.##.#..# #.###.##..
# ####.#.... .#..#.##.. .######...
# ...#.#.#.# ###.##.#.. .##...####
#
# ...#.#.#.# ###.##.#.. .##...####
# ..#.#.###. ..##.##.## #..#.##..#
# ..####.### ##.#...##. .#.#..#.##
# #..#.#..#. ...#.#.#.. .####.###.
# .#..####.# #..#.#.#.# ####.###..
# .#####..## #####...#. .##....##.
# ##.##..#.. ..#...#... .####...#.
# #.#.###... .##..##... .####.##.#
# #...###... ..##...#.. ...#..####
# ..#.#....# ##.#.#.... ...##.....
#
# For reference, the IDs of the above tiles are:
#
# 1951    2311    3079
# 2729    1427    2473
# 2971    1489    1171
#
# To check that you've assembled the image correctly, multiply the IDs
# of the four corner tiles together. If you do this with the assembled
# tiles from the example above, you get 1951 * 3079 * 2971 * 1171 =
# 20899048083289.
#
# Assemble the tiles into an image. What do you get if you multiply
# together the IDs of the four corner tiles?
#
# --- Part Two ---
#
# Now, you're ready to check the image for sea monsters.
#
# The borders of each tile are not part of the actual image; start by removing them.
#
# In the example above, the tiles become:
#
# .#.#..#. ##...#.# #..#####
# ###....# .#....#. .#......
# ##.##.## #.#.#..# #####...
# ###.#### #...#.## ###.#..#
# ##.#.... #.##.### #...#.##
# ...##### ###.#... .#####.#
# ....#..# ...##..# .#.###..
# .####... #..#.... .#......
#
# #..#.##. .#..###. #.##....
# #.####.. #.####.# .#.###..
# ###.#.#. ..#.#### ##.#..##
# #.####.. ..##..## ######.#
# ##..##.# ...#...# .#.#.#..
# ...#..#. .#.#.##. .###.###
# .#.#.... #.##.#.. .###.##.
# ###.#... #..#.##. ######..
#
# .#.#.### .##.##.# ..#.##..
# .####.## #.#...## #.#..#.#
# ..#.#..# ..#.#.#. ####.###
# #..####. ..#.#.#. ###.###.
# #####..# ####...# ##....##
# #.##..#. .#...#.. ####...#
# .#.###.. ##..##.. ####.##.
# ...###.. .##...#. ..#..###
#
# Remove the gaps to form the actual image:
#
# .#.#..#.##...#.##..#####
# ###....#.#....#..#......
# ##.##.###.#.#..######...
# ###.#####...#.#####.#..#
# ##.#....#.##.####...#.##
# ...########.#....#####.#
# ....#..#...##..#.#.###..
# .####...#..#.....#......
# #..#.##..#..###.#.##....
# #.####..#.####.#.#.###..
# ###.#.#...#.######.#..##
# #.####....##..########.#
# ##..##.#...#...#.#.#.#..
# ...#..#..#.#.##..###.###
# .#.#....#.##.#...###.##.
# ###.#...#..#.##.######..
# .#.#.###.##.##.#..#.##..
# .####.###.#...###.#..#.#
# ..#.#..#..#.#.#.####.###
# #..####...#.#.#.###.###.
# #####..#####...###....##
# #.##..#..#...#..####...#
# .#.###..##..##..####.##.
# ...###...##...#...#..###
#
# Now, you're ready to search for sea monsters! Because your image is
# monochrome, a sea monster will look like this:
#
#                   #
# #    ##    ##    ###
#  #  #  #  #  #  #
#
# When looking for this pattern in the image, the spaces can be
# anything; only the # need to match. Also, you might need to rotate
# or flip your image before it's oriented correctly to find sea
# monsters. In the above image, after flipping and rotating it to the
# appropriate orientation, there are two sea monsters (marked with O):
#
# .####...#####..#...###..
# #####..#..#.#.####..#.#.
# .#.#...#.###...#.##.O#..
# #.O.##.OO#.#.OO.##.OOO##
# ..#O.#O#.O##O..O.#O##.##
# ...#.#..##.##...#..#..##
# #.##.#..#.#..#..##.#.#..
# .###.##.....#...###.#...
# #.####.#.#....##.#..#.#.
# ##...#..#....#..#...####
# ..#.##...###..#.#####..#
# ....#.##.#.#####....#...
# ..##.##.###.....#.##..#.
# #...#...###..####....##.
# .#.##...#.##.#.#.###...#
# #.###.#..####...##..#...
# #.###...#.##...#.##O###.
# .O##.#OO.###OO##..OOO##.
# ..O#.O..O..O.#O##O##.###
# #.#..##.########..#..##.
# #.#####..#.#...##..#....
# #....##..#.#########..##
# #...#.....#..##...###.##
#   #..###....##.#...##.##.#
#
# Determine how rough the waters are in the sea monsters' habitat by
# counting the number of # that are not part of a sea monster. In the
# above example, the habitat's water roughness is 273.

using Printf
using ArgParse


function inputLoad(fname)
  readlines(fname)
end


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


function tileGetBaseId(tid)
  i = findfirst(isequal('-'), tid)
  if i != nothing
    bid = tid[1:i-1]
  else
    bid = tid
  end

  return bid
end


function dataIdentity(data::Array{String,1})
  data
end

function dataFlipVertical(data::Array{String,1})
  reverse(data)
end

function dataFlipHorizontal(data::Array{String,1})
  [reverse(d) for d in data]
end

function dataRotateLeft(data::Array{String,1})
  [join([data[r][c] for r in 1:length(data)],"") for c in length(data[1]):-1:1]
end

function dataRotateRight(data::Array{String,1})
  [join([data[r][c] for r in length(data):-1:1],"") for c in 1:length(data[1])]
end


# NB - all possible unique transformations of a 2D image
dataTransformations = Dict(
  "I"   => [dataIdentity],
  "IR1" => [dataRotateRight],
  "IR2" => [dataRotateRight, dataRotateRight],
  "IR3" => [dataRotateRight, dataRotateRight, dataRotateRight],  
  "V"   => [dataFlipVertical],
  "VR1" => [dataFlipVertical, dataRotateRight],
  "VR2" => [dataFlipVertical, dataRotateRight, dataRotateRight],
  "VR3" => [dataFlipVertical, dataRotateRight, dataRotateRight, dataRotateRight]
  )


function dataRemoveBorder(data)
  [data[r][2:end-1] for r in 2:(length(data)-1)]
end


function tilesAreVariants(t1, t2)
  # NB - uses base id to detect if two tiles
  #      are transforms of each other
  return tileGetBaseId(t1.id) == tileGetBaseId(t2.id)
end


function createTiles(lines)
  tiles = Dict{String, Tile}()
  idx = 1
  while idx <= length(lines)

    m = match.(r"^Tile (\d+):", lines[idx])
    if m != nothing
      id = string(m.captures[1])

      data = String[]
      idx += 1
      while ((idx <= length(lines)) && (length(lines[idx]) > 0))
        push!(data, lines[idx])
        idx += 1
      end

      # NB - There are eight unique rotated and flipped versions
      #      of a tile
      #
      # 1. Unchanged
      # 2. Rotated right once
      # 3. Rotated right twice
      # 4. Rotated right three times
      # 5. Vertical flipped
      # 6. Vertical flipped, rotated right once
      # 7. Vertical flipped, rotated right twice
      # 8. Vertical flipped, rotated right three times
      for tform in keys(dataTransformations)
        tiledata = deepcopy(data)
        for f in dataTransformations[tform]
          tiledata = f(tiledata)
        end

        tid = id * "-" * tform
        tiles[tid] = Tile(tid, tiledata)
      end
      
    end

    idx += 1
  end

  return tiles
end


function buildEdgeMap(tiles)
  edges = Dict{Int64, Set{String}}()
  for t in values(tiles)
    for b in [t.top, t.bottom, t.left, t.right]
      if !haskey(edges, b)
        edges[b] = Set{String}()
      end
      push!(edges[b], t.id)
    end
  end

  return edges
end


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


function assemblePicture(grid::Array{String,2}, tiles::Dict{String,Tile})
  gridSize = size(grid)[1]
  tileSize = length(tiles[grid[1,1]].data)

  picture = String[]
  for row in 1:gridSize
    stripe  = [dataRemoveBorder(tiles[tid].data) for tid in grid[row,:]]
    picture = vcat(picture, [reduce(*, v) for v in zip(stripe...)])
  end

  return picture
end


# Monster info
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


function drawMonsters(picture, monsterStarts)
  newpic = deepcopy(picture)
  for (r,c) in monsterStarts
    for mc in monsterCoords
      pixels = newpic[r-mc[1]]
      newpic[r-mc[1]] = pixels[1:(c+mc[2]-1)] * "O" * pixels[(c+mc[2]+1):end]
    end
  end

  return newpic
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

  lines = inputLoad(args["input"]);

  # Create tiles
  tiles = createTiles(lines);

  # Pre-compute list of tiles with edge values, this is used
  # as a cache to find potential candidates with matching
  # edges
  edges = buildEdgeMap(tiles);

  gridSize = Int(sqrt(length(tiles)/8));
  grid = fill("", (gridSize,gridSize));

  rv = findSolution(tiles, edges, grid, 1, 1);
  if rv == false
    error("No solution found for part 1")
  end

  println("Part 1 solution found:")
  corners = vec([parse(Int,tileGetBaseId(grid[r,c])) for r in [1,gridSize], c in [1, gridSize]])
  cprod   = reduce(*, corners)
  @printf("Product of corners: %d\n", cprod)

  if args["part"] == "part1"
    exit()
  end

  # Assemble the picture
  picture = assemblePicture(grid, tiles)

  # Check all possible picture orientations
  found = false
  for tform in keys(dataTransformations)
    data = deepcopy(picture)
    for f in dataTransformations[tform]
      data = f(data)
    end

    monsterStarts = findMonsters(data);
    if length(monsterStarts) > 0
      picture = drawMonsters(data, monsterStarts);
      found   = true;
      break
    end
  end

  if found
    println("Solution to part2 found!")
    roughness = sum([sum([c=='#' for c in l]) for l in picture])
    @printf("Roughness is %d\n", roughness)
    
  else
    error("Solution to Part2 not found")
  end
  
end

main()
