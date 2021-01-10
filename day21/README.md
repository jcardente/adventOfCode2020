# Day 21 Solutions

[Day 21](https://adventofcode.com/2020/day/21) involved deciphering
ingredients in a foreign language and associating them with allergens.

The puzzle input was a list of foods each with one or more ingredients and allergens. The
rules were,

- Each allergen is found in exactly one ingredient
- Each ingredient contains zero or one allergen
- Allergens aren't always listed
- When an allergen is listed, the associated ingredient is also listed

The following is an example of the puzzle input,

```
mxmxvkd kfcds sqjhc nhms (contains dairy, fish)
trh fvjkl sbzzf mxmxvkd (contains dairy)
sqjhc fvjkl (contains soy)
sqjhc mxmxvkd sbzzf (contains fish)
```

For part 1, the task was to identify the ingredients that could not
possibly contain an allergen. To start, I built a bi-partite graph
with edges between ingredients and allergens. The graph maintained
counts for both nodes and edges

```julia
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
```

Finding safe ingredients was then just a matter of identifying those
did not have any ingredient-allergen edge counts higher then the
associated allergen count.

```julia
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
```

For part 2, the goal was to determine the ingredient associated with
each allergen. This problem was similar to that of 
[day 16](https://github.com/jcardente/adventOfCode2020/tree/main/day16) 
in that,

- The set of possible ingredients for an allgergen was a superset of those 
  for other allergens
- There was only one allergen with only one possible ingredient

I wrote a routine that,

- Compiled the list of possible ingredients for each allergen
  based on edge and allergen counts
- Iteratively assigned ingredients to allergens until all were
  were found
  
```julia
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
```

Final solution can be run from the command line,

```
% julia soln_day21.jl -h
usage: soln_day21.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
