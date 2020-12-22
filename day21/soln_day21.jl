# ------------------------------------------------------------
# Solution to Advent of Code 2020 Puzzle Day 21
#
# PUZZLE:
#
# --- Day 21: Allergen Assessment ---
# 
# You reach the train's last stop and the closest you can get to your
# vacation island without getting wet. There aren't even any boats
# here, but nothing can stop you now: you build a raft. You just need
# a few days' worth of food for your journey.
# 
# You don't speak the local language, so you can't read any
# ingredients lists. However, sometimes, allergens are listed in a
# language you do understand. You should be able to use this
# information to determine which ingredient contains which allergen
# and work out which foods are safe to take with you on your trip.
# 
# You start by compiling a list of foods (your puzzle input), one food
# per line. Each line includes that food's ingredients list followed
# by some or all of the allergens the food contains.
# 
# Each allergen is found in exactly one ingredient. Each ingredient
# contains zero or one allergen. Allergens aren't always marked; when
# they're listed (as in (contains nuts, shellfish) after an
# ingredients list), the ingredient that contains each listed allergen
# will be somewhere in the corresponding ingredients list. However,
# even if an allergen isn't listed, the ingredient that contains that
# allergen could still be present: maybe they forgot to label it, or
# maybe it was labeled in a language you don't know.
# 
# For example, consider the following list of foods:
# 
# mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
# trh fvjkl sbzzf mxmxvkd (contains dairy)
# sqjhc fvjkl (contains soy)
# sqjhc mxmxvkd sbzzf (contains fish)
# 
# The first food in the list has four ingredients (written in a
# language you don't understand): mxmxvkd, kfcds, sqjhc, and
# nhms. While the food might contain other allergens, a few allergens
# the food definitely contains are listed afterward: dairy and fish.
# 
# The first step is to determine which ingredients can't possibly
# contain any of the allergens in any food in your list. In the above
# example, none of the ingredients kfcds, nhms, sbzzf, or trh can
# contain an allergen. Counting the number of times any of these
# ingredients appear in any ingredients list produces 5: they all
# appear once each except sbzzf, which appears twice.
# 
# Determine which ingredients cannot possibly contain any of the
# allergens in your list. How many times do any of those ingredients
# appear?
#
# --- Part Two ---
# 
# Now that you've isolated the inert ingredients, you should have
# enough information to figure out which ingredient contains which
# allergen.
# 
# In the above example:
# 
# mxmxvkd contains dairy.
# sqjhc contains fish.
# fvjkl contains soy.
# 
# Arrange the ingredients alphabetically by their allergen and
# separate them by commas to produce your canonical dangerous
# ingredient list. (There should not be any spaces in your canonical
# dangerous ingredient list.) In the above example, this would be
# mxmxvkd,sqjhc,fvjkl.
# 
# Time to stock your raft with supplies. What is your canonical
# dangerous ingredient list?

using Printf
using ArgParse


function inputLoad(fname)
  lines = readlines(fname)  
end


function buildIngAgnGraph(lines)
  ingredients = Dict{String,Int64}()
  allergens   = Dict{String,Int64}()
  edges       = Dict{String, Dict{String,Int64}}()

  for l in lines
    l = replace(l, "("=>"")
    l = replace(l, ")"=>"")

    ing, agn = split(l, "contains")
    inglist = [strip(s) for s in split(strip(ing), ' ')]
    agnlist   = [strip(s) for s in split(strip(agn), ',')]

    for i in inglist
      if !haskey(ingredients, i)
        ingredients[i] = 0
      end
      ingredients[i] += 1
    end

    for a in agnlist
      if !haskey(allergens, a)
        allergens[a] = 0
      end
      allergens[a] += 1
    end

    for i in inglist
      for a in agnlist
        # Ingredient to allergen
        if !haskey(edges, i)
          edges[i] = Dict{String,Int64}()
        end

        if !haskey(edges[i], a)
          edges[i][a] = 0
        end
        edges[i][a] += 1

        # Allergen to ingredient
        if !haskey(edges, a)
          edges[a] = Dict{String,Int64}()
        end

        if !haskey(edges[a], i)
          edges[a][i] = 0
        end
        edges[a][i] += 1                
      end
    end
  end

  return ingredients, allergens, edges
end


function findSafeIngredients(ingredients, allergens, edges)
  # NB - safe ingredients have no allergen edge counts
  #      equal to or greater than the total allergen count
  safeIngredients = String[]
  for ing in keys(ingredients)
    issafe = true
    for (ang, ecount) in edges[ing]
      acount = allergens[ang]
      if ecount >= acount
        issafe = false
      end      
    end

    if issafe
      push!(safeIngredients, ing)
    end    
  end

  return safeIngredients
end


function assignIngredientsToAllergens(allergens, edges)
  # Determine possible ingredients for each allergen
  agnToMaybe = Dict{String,Array{String,1}}();
  for (agn, acount) in allergens
    # Possible ingredients must have an edge count equal to or greater than
    # this allergen count
    possible = Array{String,1}()
    for (ign, ecount) in edges[agn]
      if ecount >= acount
        push!(possible, ign)
      end
    end
    agnToMaybe[agn] = possible
  end

  agnToIgn = Dict{String,String}()
  ignAssigned = Set{String}()
  while length(agnToMaybe) > 0

    # NB - During each iteration, there should be
    #      one or more allergens with only one
    #      possible ingredient. Assign those and
    #      then remove them from the list maybe lists
    for (agn, maybes) in agnToMaybe
      if length(maybes) == 1
        # Found an assignment!
        agnToIgn[agn] = maybes[1]
        push!(ignAssigned, maybes[1])
      end      
    end

    newAgnToMaybes = Dict{String, Array{String,1}}()
    for (agn, maybes) in agnToMaybe
      if !haskey(agnToIgn, agn)
        # Allergen still unassigned
        newAgnToMaybes[agn] = filter(ign -> !(ign in ignAssigned), maybes)
      end      
    end
    agnToMaybe = newAgnToMaybes
  end

  return agnToIgn
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
  lines = inputLoad(args["input"])

  ingredients, allergens, edges = buildIngAgnGraph(lines)

  safeIngredients = findSafeIngredients(ingredients, allergens, edges)
  @printf("Found %d safe ingredients: %s\n",
          length(safeIngredients),
          join(safeIngredients, ", "))

  p1count = 0
  for ing in safeIngredients
    p1count += ingredients[ing]
  end
  @printf("Part 1 answer: %d\n", p1count)

  if args["part"] == "part1"
    exit()
  end

  agnToIgn = assignIngredientsToAllergens(allergens, edges)  
  if !all([haskey(agnToIgn, agn) for agn in keys(allergens)])
    @error("Not all allergens assigned to an ingredient!")
  end

  ignAgnPairs = [(ign, agn) for (agn,ign) in agnToIgn]
  sort!(ignAgnPairs, by= p -> p[2])

  part2 = join([p[1] for p in ignAgnPairs],",")
  @printf("Part 2 solution: %s\n", part2)
end

main()
