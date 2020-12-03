# ------------------------------------------------------------
# Solution to Advent of Code 2020 Puzzle Day 2
#
# PUZZLE:
#
#
# Your flight departs in a few days from the coastal airport; the
# easiest way down to the coast from here is via toboggan.
#
# The shopkeeper at the North Pole Toboggan Rental Shop is having a bad
# day. "Something's wrong with our computers; we can't log in!" You ask
# if you can take a look.
#
# Their password database seems to be a little corrupted: some of the
# passwords wouldn't have been allowed by the Official Toboggan
# Corporate Policy that was in effect when they were chosen.
#
# To try to debug the problem, they have created a list (your puzzle
# input) of passwords (according to the corrupted database) and the
# corporate policy when that password was set.
#
# For example, suppose you have the following list:
#
# 1-3 a: abcde
# 1-3 b: cdefg
# 2-9 c: ccccccccc
#
# Each line gives the password policy and then the password. The
# password policy indicates the lowest and highest number of times a
# given letter must appear for the password to be valid. For example,
# 1-3 a means that the password must contain a at least 1 time and at
# most 3 times.
#
# In the above example, 2 passwords are valid. The middle password,
# cdefg, is not; it contains no instances of b, but needs at least
# 1. The first and third passwords are valid: they contain one a or nine
# c, both within the limits of their respective policies.
#
# How many passwords are valid according to their policies?
#
# --- Part Two ---
#
# While it appears you validated the passwords correctly, they don't
# seem to be what the Official Toboggan Corporate Authentication System
# is expecting.
#
# The shopkeeper suddenly realizes that he just accidentally explained
# the password policy rules from his old job at the sled rental place
# down the street! The Official Toboggan Corporate Policy actually works
# a little differently.
#
# Each policy actually describes two positions in the password, where 1
# means the first character, 2 means the second character, and so
# on. (Be careful; Toboggan Corporate Policies have no concept of "index
# zero"!) Exactly one of these positions must contain the given
# letter. Other occurrences of the letter are irrelevant for the
# purposes of policy enforcement.
#
# Given the same example list from above:
#
# 1-3 a: abcde is valid: position 1 contains a and position 3 does not.
# 1-3 b: cdefg is invalid: neither position 1 nor position 3 contains b.
# 2-9 c: ccccccccc is invalid: both position 2 and position 9 contain c.
#
# How many passwords are valid according to the new interpretation of
# the policies?

using Printf
using ArgParse


function inputLoad(fname)
  readlines(fname)
end


function parseEntryString(entry_string)
  i   = nothing
  j   = nothing
  c   = nothing
  pwd = nothing

  m = match(r"^([0-9]+)-([0-9]+) ([a-z]): ([a-z]+)$", entry_string)

  if m.captures != nothing    
    i   = parse(Int, m.captures[1])
    j   = parse(Int, m.captures[2])
    c   = first(m.captures[3])  # NB - converts string to char
    pwd = m.captures[4]
  end

  return i, j, c, pwd
end


function checkPolicy1(c, pmin, pmax, pwd)
  #n = sum([Int(c==x) for x in collect(pwd)])
  #n = length(filter(x -> x == c, collect(pwd)))
  n = count(x -> x == c, collect(pwd))
  return (n >= pmin) && (n <= pmax)
end


function checkPolicy2(c, p1, p2, pwd)
  chars = collect(pwd)
  return ((chars[p1] == c && chars[p2]!=c) ||
          (chars[p1] != c && chars[p2]==c))
end


PolicyFunctions = Dict(
  "policy1" => checkPolicy1,
  "policy2" => checkPolicy2
)


function parseCommandLine()
  s = ArgParseSettings()
  @add_arg_table s begin
    "input"
      help = "Input file"
      required = true
    "policy"
      help = "Policy to check, policy1 or policy2"
      required = true
  end

  return parse_args(s)
end


function main()

  args = parseCommandLine()
  
  entries = inputLoad(args["input"])

  if !haskey(PolicyFunctions, args["policy"])
    @printf("Error, policy argument invalid\n")
    return
  end
  policyfn = PolicyFunctions[args["policy"]]
  
  nvalid = 0
  for entry in entries
    i, j, c, pwd = parseEntryString(entry)
    
    if all([x != nothing for x in (i, j, c, pwd)])      
      if policyfn(c, i, j, pwd) == true
        nvalid += 1
      end
      
    else
      @printf("Oops, had trouble with %s\n", entry)      
    end
  end

  @printf("Found %d valid passwords\n", nvalid)
  
end


main()
