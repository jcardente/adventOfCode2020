# ------------------------------------------------------------
# Solution to Advent of Code 2020 Puzzle Day 16
#
# PUZZLE:
#
# --- Day 16: Ticket Translation ---
# 
# As you're walking to yet another connecting flight, you realize that
# one of the legs of your re-routed trip coming up is on a high-speed
# train. However, the train ticket you were given is in a language you
# don't understand. You should probably figure out what it says before
# you get to the train station after the next flight.
# 
# Unfortunately, you can't actually read the words on the ticket. You
# can, however, read the numbers, and so you figure out the fields
# these tickets must have and the valid ranges for values in those
# fields.
# 
# You collect the rules for ticket fields, the numbers on your ticket,
# and the numbers on other nearby tickets for the same train service
# (via the airport security cameras) together into a single document
# you can reference (your puzzle input).
# 
# The rules for ticket fields specify a list of fields that exist
# somewhere on the ticket and the valid ranges of values for each
# field. For example, a rule like class: 1-3 or 5-7 means that one of
# the fields in every ticket is named class and can be any value in
# the ranges 1-3 or 5-7 (inclusive, such that 3 and 5 are both valid
# in this field, but 4 is not).
# 
# Each ticket is represented by a single line of comma-separated
# values. The values are the numbers on the ticket in the order they
# appear; every ticket has the same format. For example, consider this
# ticket:
# 
# .--------------------------------------------------------.
# | ????: 101    ?????: 102   ??????????: 103     ???: 104 |
# |                                                        |
# | ??: 301  ??: 302             ???????: 303      ??????? |
# | ??: 401  ??: 402           ???? ????: 403    ????????? |
# '--------------------------------------------------------'
# 
# Here, ? represents text in a language you don't understand. This
# ticket might be represented as
# 101,102,103,104,301,302,303,401,402,403; of course, the actual train
# tickets you're looking at are much more complicated. In any case,
# you've extracted just the numbers in such a way that the first
# number is always the same specific field, the second number is
# always a different specific field, and so on - you just don't know
# what each position actually means!
# 
# Start by determining which tickets are completely invalid; these are
# tickets that contain values which aren't valid for any field. Ignore
# your ticket for now.
# 
# For example, suppose you have the following notes:
# 
# class: 1-3 or 5-7
# row: 6-11 or 33-44
# seat: 13-40 or 45-50
# 
# your ticket:
# 7,1,14
# 
# nearby tickets:
# 7,3,47
# 40,4,50
# 55,2,20
# 38,6,12
# 
# It doesn't matter which position corresponds to which field; you can
# identify invalid nearby tickets by considering only whether tickets
# contain values that are not valid for any field. In this example,
# the values on the first nearby ticket are all valid for at least one
# field. This is not true of the other three nearby tickets: the
# values 4, 55, and 12 are are not valid for any field. Adding
# together all of the invalid values produces your ticket scanning
# error rate: 4 + 55 + 12 = 71.
# 
# Consider the validity of the nearby tickets you scanned. What is
# your ticket scanning error rate?
#
# --- Part Two ---
# 
# Now that you've identified which tickets contain invalid values,
# discard those tickets entirely. Use the remaining valid tickets to
# determine which field is which.
# 
# Using the valid ranges for each field, determine what order the
# fields appear on the tickets. The order is consistent between all
# tickets: if seat is the third field, it is the third field on every
# ticket, including your ticket.
# 
# For example, suppose you have the following notes:
# 
# class: 0-1 or 4-19
# row: 0-5 or 8-19
# seat: 0-13 or 16-19
# 
# your ticket:
# 11,12,13
# 
# nearby tickets:
# 3,9,18
# 15,1,5
# 5,14,9
# 
# Based on the nearby tickets in the above example, the first position
# must be row, the second position must be class, and the third
# position must be seat; you can conclude that in your ticket, class
# is 12, row is 11, and seat is 13.
# 
# Once you work out which field is which, look for the six fields on
# your ticket that start with the word departure. What do you get if
# you multiply those six values together?


using Printf
using ArgParse



function inputLoad(fname)
  lines = readlines(fname)
end


struct TicketRule
  name::String
  range1::Tuple{Int64, Int64}
  range2::Tuple{Int64, Int64}
end

TicketRule(n::String, r1l::Int, r1h::Int, r2l::Int, r2h::Int) = TicketRule(n, (r1l, r1h), (r2l, r2h)) 


function ruleCheck(r::TicketRule, v::Int)
  ((r.range1[1] <= v && v <= r.range1[2]) ||
   (r.range2[1] <= v && v <= r.range2[2]))
end


function processInput(lines)

  # Process rules
  idx = 1
  rules = TicketRule[]
  while length(lines[idx]) > 0
    m = match(r"^([\w ]+): (\d+)-(\d+) or (\d+)-(\d+)$", lines[idx])
    if ((m != nothing) && length(m.captures) == 5)

      push!(rules, TicketRule(
        string(m.captures[1]),
        parse(Int, m.captures[2]),
        parse(Int, m.captures[3]),
        parse(Int, m.captures[4]),
        parse(Int, m.captures[5])))

    else
      error("Error processing rule: " * lines[idx])
    end
    
    idx += 1
  end

  # Process our ticket
  while !(startswith(lines[idx], "your ticket:"))
    idx += 1
  end
  idx += 1
  ticket = [parse(Int, s) for s in split(lines[idx], ",")]
  
  # Process nearby tickets
  while !(startswith(lines[idx], "nearby tickets:"))
    idx += 1
  end
  idx += 1

  nearbyTickets = Array{Int, 1}[]
  while idx <= length(lines)
    push!(nearbyTickets, [parse(Int, s) for s in split(lines[idx], ",")])
    idx+=1
  end
  
  return rules, ticket, nearbyTickets
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

  lines = inputLoad(args["input"])
  rules, ticket, nearbyTickets = processInput(lines)


  if args["part"] == "part1"
    fieldvalues = collect(Iterators.flatten(nearbyTickets))
    badvalues = filter((v) -> !any([ruleCheck(r,v) for r in rules]),
                       fieldvalues)
    badsum = sum(badvalues)

    @printf("Part 1 answer: %d\n", badsum)

  else

    # Keep the valid tickets
    goodTickets = filter(
      t ->
      all([any([ruleCheck(r,v) for r in rules]) for v in t]),
      nearbyTickets)

    # Find all the potential mappings, some fields are valid
    # for multiple rules
    push!(goodTickets, ticket)
    maybeRuleIdxs = Dict{String, Set{Int64}}()
    idxsToCheck = [i for i in 1:length(goodTickets[1])]
    for r in rules
      maybeRuleIdxs[r.name] = Set{Int64}()
      for idx in idxsToCheck
        if all([ruleCheck(r,t[idx]) for t in goodTickets])
          push!(maybeRuleIdxs[r.name], idx)
        end
      end
    end

    # Determine actual rule idxs. The puzzle is designed
    # such that:
    # - Each rule's possible indexes is a superset of another
    #   rule with one additional index
    # - There is one rule with only one possible index
    #
    # solution can be found by successively interating
    # over rules in order of number of possible indexes
    # and finding the only value not yet assigned.
    ruleIdxs = Dict{String, Int64}()
    ruleOrder = [i[1] for i in
                 sort([(k, length(v)) for (k,v) in pairs(maybeRuleIdxs)],
                     by= x -> x[2])]

    assignedIdxs = Set{Int64}()
    for r in ruleOrder
      available = setdiff(maybeRuleIdxs[r], assignedIdxs)
      
      if length(available) > 1
        error("Rule " * r * " has too many possible indexes")
      end
      
      idx = first(available)
      push!(assignedIdxs, idx)
      ruleIdxs[r] = idx
    end
    
    fieldsToGet = filter(n -> startswith(n, "departure "),
                         keys(ruleIdxs))
    ticketValues = [ticket[ruleIdxs[f]] for f in fieldsToGet]
    
    @printf("Part 2 answer: %d\n", reduce(*, ticketValues))
  end
  
  
end

main()
