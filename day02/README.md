# Solution to Day 2 Puzzles

Both puzzles on Day 2 shared the same form of:

1. Read a list of strings storing passwords and policies
2. Parse and check the policy for each password
3. Count the number of valid passwords

The input strings had the form of:

```
i-j c: pwd
```

Where:
- `i` is an integer
- `j` is an integer
- `c` is a lowercase character [a-z]
- `pwd` is a lowercase string of characters [a-z] 

I used a regular expression to parse the string. There may be easier and more
idiomatic ways to do this in Julia but this worked.

```julia
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
```

In the first puzzle, `i` and `j` where the minimum and maximum 
number of times `c` should appear in `pwd`. I found a couple
of ways to do this in Julia,

```julia
function checkPolicy1(c, pmin, pmax, pwd)
  #n = sum([Int(c==x) for x in collect(pwd)])
  #n = length(filter(x -> x == c, collect(pwd)))
  n = count(x -> x == c, collect(pwd))
  return (n >= pmin) && (n <= pmax)
end
```

In the second puzzle, `i` and `j` represented locations in 
`pwd` in which `c` must appear but only once. I considered
ways to use list comprehensions but settled on basic logic
expressions,

```julia
function checkPolicy2(c, p1, p2, pwd)
  chars = collect(pwd)
  return ((chars[p1] == c && chars[p2]!=c) ||
          (chars[p1] != c && chars[p2]==c))
end
```

Since both puzzles used the same basic loop, I stored pointers to the
`checkPolicy1()` and `checkPolicy2()` functions in a dictionary and
used command line argument to pick the right one. 

The final solution can be run from the command line with the following
arguments,

```
% julia soln_d02.jl --help
usage: soln_d02.jl [-h] input policy

positional arguments:
  input       Input file
  policy      Policy to check, policy1 or policy2

optional arguments:
  -h, --help  show this help message and exit
```

