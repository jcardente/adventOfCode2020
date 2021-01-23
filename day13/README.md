# Day 13 Solutions

[Day 13](https://adventofcode.com/2020/day/13) was.... fun. It involved predicting
the schedules for shuttle busses that departed at different intervals. 

The puzzle input was the earliest time you could take a shuttle and a
list of shuttle bus IDs that also specified their departing
intervals. For example, given the input

```
939
7,13,x,x,59,x,31,19
```

The earliest time you could catch a shuttle was timestamp 939. Bus `7`
departed at 7, 14, 21, 28, etc. Similarly, bus `13` departed at 13, 26,
39, etc.

For part 1, the task was to determine the first departing shuttle
after the given earliest departure time. I wrote a routine that, given
a bus id and a timestamp, calculated the time to next departure,

```julia
function busTimeToDepart(busid, tstamp)
  return Int(ceil(tstamp/busid)*busid) % tstamp
end
```

Finding the first bus to depart after the specified timestamp was
just a matter of,

- Calculating the time to next departure for each bus
- Sorting the shuttles in ascending order according to next departing
- Taking the bus associated with the earliest time

The code for this was,

```julia
departs = [(id, busTimeToDepart(id,tstamp)) for id in busids]
sort!(departs, by = x -> x[2])

firstbusid, waittime = first(departs)
@printf("Earliest bus %d in %d minutes\n", firstbusid, waittime)
```

Part 2 was... harder. It required finding the earliest time at which
the busses departed,

- In the order given in the input list
- And at relative times based on their positions in the list

For example, given the input above, the goal was to find a timestamp `t` such that,

- Bus ID 7 departs at timestamp `t`
- Bus ID 13 departs one minute after timestamp `t`
- There are no requirements or restrictions on departures at two or three minutes after timestamp `t`
- Bus ID 59 departs four minutes after timestamp `t`
- There are no requirements or restrictions on departures at five minutes after timestamp `t`
- Bus ID 31 departs six minutes after timestamp `t`
- Bus ID 19 departs seven minutes after timestamp `t`

This was one of the toughest puzzles in the competition. Naive solutions were extremely inefficient.
I noticed that the bus ids were primes and remembered from graduate cryptography classes that modulo 
arthmetic has some interesting properties when working with [relative primes](https://en.wikipedia.org/wiki/Coprime_integers).
But, I couldn't see the solution and eventually checked the subreddit for a hint. 

The key to solving the puzzle was the [Chinese Remainder Theorem](https://en.wikipedia.org/wiki/Chinese_remainder_theorem)
which I had never seen before. A detailed explanation of the theorem is beyond the scope of this README. 
However, the first important concept to understand is that if

```
2 = 2 mod 5
```

the same is true for any non-negative integer `n` such that,

```
2 = (2 + n*5) mod 5
```

and other equations with different modulos,

```
3 = (3 + m*7) mod 7
```

Something cool happens when we set `n=7` and `m=5`, the remainders stay the same!

```
2 = (2 + 7*5) mod 5
3 = (3 + 5*7) mod 7
```

and that stays true for any multiple of the `n*m` products. It also stays true
if a third modulo equation is added to the mix,

```
2 = (2 + 11*7*5) mod 5
3 = (3 + 11*5*7) mod 7
8 = (8 + 11*5*7) mod 11
```

For all this to to work, it's essential for the modulo divisors to be coprime - in this case 5, 7, and 11.

This property formed the foundation for the solution which basically consisted of,

1. Initialize `t=0` and `p=1`
2. For a given bus id
    - Keep incrementing `t` by `p` until the desired remainder is found
3. Multiply `p` by the busid
4. Pick the next busid and repeat starting at 2

This process yielded the first time that satisfied all of the busid departing time
criteria. The code for this was,

```julia
busids = [(id, i-1) for (i,id) in enumerate(busids)];
busids = [(parse(Int, id), i) for (id,i) in filter(x -> x[1] != "x", busids)]

# NB - use the Chinese Remainder Thereom
time = 0
lcm  = 1
for (bid, idx) in busids
  while ((time+idx) % bid) != 0
   time += lcm
  end
 lcm *= bid
end
@printf("First timestamp the meets criteria: %d\n",time)    
```

Final solution can be run from the command line,

```
% julia soln_day13.jl -h
usage: soln_day13.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```


