# Day 25 Solutions

[Day 25](https://adventofcode.com/2020/day/25) required finding the
private keys in an RSA like cryptographic handshake between a door
lock and room key card.

The cryptographic handshake was based on the following transformation operation,

- Start with an initial "subject" number
- Initialize a value variable to 1
- Do the following a set number of times
  - Set the value to itself multiplied by the subject number
  - Set the value to the remainder after dividing by 20201227

The unknown secrets were the number of times the door lock and key
card performed these operations. 

The cryptographic handshake consisted of,

- The key card computes a public key using the subject value 7
  and a secret loop size
- The door computes a public key key using the subject value 7
  and a different secret loop size
- The public keys are exchanged
- The card computes a new key using the door's public key as the
  subject value and its secret loop size
- The door computes a new key using the card's public key as the
  subject value and its secret loop size
  
The puzzle input was the door's and card's public key. Each could
be used to find secret loop size through a simple brute force
algorithm. Once one secret loop size was found, the final encryption
key could be calculated. 

This being Christmas day, the solution was fairly trivial and simply
required implementing the brute force algorithm described in the puzzle
description,

```julia
function findLoopSize(subnum, pk)
  v = 1
  loopsize = 0
  while true
    loopsize += 1
    v = (v * subnum) % 20201227
    if v == pk
      break
    end    
  end

  return loopsize
end


function calcEncryptionKey(loopsize, subnum)
  v = 1
  for i in 1:loopsize
    v = (v * subnum) % 20201227
  end
  return v
end


function main()  
  args = parseCommandLine()  

  pk1, pk2 = inputLoad(args["input"])
      
  ls1 = findLoopSize(7, pk1)
  ls2 = findLoopSize(7, pk2)
  @printf("Loop counts: %d %d\n", ls1, ls2)

  encryptionKey = calcEncryptionKey(ls1, pk2)
  @printf("Encryption key: %d\n", encryptionKey)

end
```

Final solution can be run from the command line,

```
% julia soln_day25.jl -h
usage: soln_day25.jl [-h] input

positional arguments:
  input       Input file

optional arguments:
  -h, --help  show this help message and exit
```
