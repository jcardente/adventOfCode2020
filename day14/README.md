# Day 14 Solutions

[Day 14](https://adventofcode.com/2020/day/14) involved binary numbers and bitmasks used by a faulty
navigation computer.

The puzzle input was a program of the form,

```
mask = XXXXXXXXXXXXXXXXXXXXXXXXXXXXX1XXXX0X
mem[8] = 11
mem[7] = 101
mem[8] = 0
```

For part 1, the mask specified how values were modified before being stored in the specified
memory address. The mask rules were:

- an `X` leaves the associated bit unchanged
- a `1` or `0` overwrites the associated bit to the specified value

The actual puzzle containined many mask values and memory operations. 

Since there three possible mask effects,

1. No change
2. Set to 1
3. Set to 0

I parsed masks into two vectors,

1. A vector specifying the bits to set to 1
2. A vector specifying the bits to set to 0

```julia
function parseMaskString(mask)
  oneMask  = 0
  zeroMask = 0
  i = 0
  for c in reverse(mask)
    if c == '1'
      oneMask += (1 << i)
    elseif c=='0'
      zeroMask += (1 << i)
    end
    i += 1
  end
  
  return oneMask, zeroMask
end

```

This made correctly storing memory values for part one relatively straight forward, 

```julia
memory[addr] = (value | oneMask) & ~zeroMask
```

Part 2 complicated the situation by appying the mask to the address and changing the bitmask rules
such that, 

- A `0` leaves the corresponding address bit unchanged
- A `1` overwrites the corresponding address bit to `1`
- An `X` means that addresses with this bit set to `0` and `1` are written to!

The `X` behavior meant that the solution had to generate all possible address
values that matched the pattern. I solved this by iterating over the mask
and expanding the set of addresses for each `X` encountered, 

```julia
# set address bits to 1
addr  = addr | oneMask

# flip address bits
xmask = ~(oneMask | zeroMask) & ((1<<36)-1)
addrs = Int64[addr]
for i in 0:35
  checkmask = 1<<i
  if (xmask & checkmask) > 0
    append!(addrs, [xor(a,checkmask) for a in addrs])
  end
end
      
# set all flipped addresses to value
  for a in addrs
    memory[a] = value
  end
end
```

Final solution can be run from the command line,

```
% julia soln_day14.jl -h
usage: soln_day14.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
