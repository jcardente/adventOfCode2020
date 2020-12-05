# Solution to Day 4 Puzzles

Day four involves validating passport data for traveling to the
North Pole. In part 1 simply checks to see if passports have
a subset of required fields. Part 2 adds validating the data
in those fields. Both ask for the number of valid passports in the
provided data.

Passports are provided as a block of ASCII text consisting
of `field:value` key-value pairs. Data for a passport can span
a variable number of consecutive lines. Each passport is separated
by a blank line.

```
ecl:gry pid:860033327 eyr:2020 hcl:#fffffd
byr:1937 iyr:2017 cid:147 hgt:183cm

iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884
hcl:#cfa07d byr:1929

hcl:#ae17e1 iyr:2013
eyr:2024
ecl:brn pid:760753108 byr:1931
hgt:179cm
```

I wrote a function to consolidate the data for each passport
into a single string and a second function to convert that
into a Julia dicionary,

```julia
function inputLoad(fname)
  passports = String[]
  current = ""
  open(fname, "r") do f
    for line in readlines(f)
      line = strip(line)
      if !isempty(line)
        current = strip(join([current, line], " "))
        
      else
        push!(passports, current)
        current = ""
      end
    end

    if length(current) > 0
      # NB - when input doesn't end in a blank line
      #      make sure final entry is processed!
      push!(passports, current)
    end
  end
  
  return passports
end


function passportStringToDict(pstring)
  fields = split(pstring, " ", keepempty=false)
  Dict([Tuple(strip(y) for y in split(x, ":")) for x in fields])
end
```

For part 1, I wrote a function to check each passport for the
required fields and counted the number that passed,

```julia
function ruleCheckRequiredFields(pdict)
  passportSet = Set(keys(pdict))
  requiredSet = Set(["byr", "iyr", "eyr", "hgt",
                     "hcl", "ecl", "pid"])
  if issubset(requiredSet, passportSet)
    return true
  end
  return false
end

nvalid = 0
for passport in passportStrings
  pdict = passportStringToDict(passport)
    
  if ruleCheckRequiredFields(pdict)
    nvalid += 1
  end
end
@printf("Found %d valid passports\n", nvalid)
```

For part 2, I created an array of validation functions that are
iterated over for each passport. Fortunately, the Julia `all(f, itr)`
terminates early if one of the functions returns `false` which
made it unnecessary to check for required dictionary keys in the
data validation functions,

```julia
Rules = [
  ruleCheckRequiredFields,
  pdict -> utilCheckYear(pdict["byr"], 1920, 2002),
  pdict -> utilCheckYear(pdict["iyr"], 2010, 2020),
  pdict -> utilCheckYear(pdict["eyr"], 2020, 2030),
  ruleCheckHeight,
  pdict -> match(r"^#[0-9a-z]{6}$", pdict["hcl"]) != nothing,
  pdict -> pdict["ecl"] in  ["amb", "blu", "brn", "gry", "grn", "hzl", "oth"],
  pdict -> match(r"^\d{9}$", pdict["pid"]) != nothing
]

if args["part"] == "part1"
  rules = Rules[1:1]
else
  rules = Rules
end

nvalid = 0
for passport in passportStrings
  pdict = passportStringToDict(passport)
  
  if all(f -> f(pdict), rules)
    nvalid += 1
  end
end
@printf("Found %d valid passports\n", nvalid)
```

Final solution can be run from the command line to solve both parts,

```
% julia soln_d04.jl --help
usage: soln_d04.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit

```
