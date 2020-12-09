# Solution to Day 8 Puzzle

Day 8 involved simulating a simple CPU with only three instructions:
`nop`, `jmp`, and `acc`. The following simple program shows their
syntax.

```
nop +0
acc +1
jmp +4
acc +3
jmp -3
acc -99
acc +1
jmp -4
acc +6
```

Part 1 required detecting infinite loops. Part 2 involved
testing code changes to fix the infinite loop, specifically
by swapping `nop` and `jmp` instructions.

My solution centered around a simple emulator that:
- Maintains CPU state
- Decodes and executes instructions
- Throws exceptions on halting conditions


```julia
mutable struct CPU
  ip::Int64
  acc::Int64
  code::Array{String,1}
  trace::Set{Int64}
end


struct CPUException <: Exception
  cause::String
end

CPU(code::Array{String,1}) = CPU(0, 0, code, Set{Int64}())


function cpuExecute!(cpu::CPU)  
  if cpu.ip < 0 
    throw(CPUException("badip"))    
  end

  if cpu.ip >= length(cpu.code)
    throw(CPUException("terminated"))
  end
    
  if cpu.ip in cpu.trace
    throw(CPUException("loop"))
  end
  push!(cpu.trace, cpu.ip)
  
  inst = cpu.code[cpu.ip+1] # NB - ip starts at 0, arrays start at 1
  
  m    = match(r"^(?<op>[a-z]+) (?<arg>[+-][0-9]+)$", inst)
  if m==nothing
    error("Error processing instruction: " * inst)
  end
  op  = string(m[:op])
  arg = parse(Int, m[:arg])

  if op == "nop"
    cpu.ip += 1
    
  elseif op=="jmp"
    cpu.ip += arg
    
  elseif op=="acc"
    cpu.acc += arg
    cpu.ip  += 1
  else
    error("Illegal op: " * op)
  end
end


function cpuPrintState(cpu::CPU)
  @printf("IP=%d  ACC=%d\n",cpu.ip, cpu.acc)
end
```

Running a program was then a matter of repeatably stepping the 
CPU until a halting exception is thrown,

```julia
function runProgram(code)
  cpu   = CPU(code);
  cause = "unknown"
  while true
    try
      cpuExecute!(cpu)
      
    catch err
      cause = err.cause
      break
      
    end    
  end

  return cause, cpu
end
```

With that in place, solving part 1 was simply a matter of running
the test program and printing out the final CPU state,

```julia
cause, cpu = runProgram(code);

@printf("CPU halted by: %s\n", cause)
print("Final CPU State: ")
cpuPrintState(cpu)
```

To solve part 2, my solution:

- Iterates over each line of the test program
- Determines if the current instruction is a `nop` or `jmp`
- If so,
  - Convert `nop` to `jmp` or vice versus
  - Run the program
  - Determine if the halt condition was a successful termination
  
```julia
flipip = 1
while flipip < length(code)
  inst = code[flipip]
  m    = match(r"^(?<op>[a-z]+) (?<arg>[+-][0-9]+)$", inst)
  op   = string(m[:op])
  arg  = string(m[:arg])

  if op == "jmp"
    newop = "nop"
  elseif op == "nop"
    newop = "jmp"
  else
    newop = op
  end

  if op != newop
    newinst = newop * " " * arg
    newcode = deepcopy(code)
    newcode[flipip] = newinst

    cause, cpu = runProgram(newcode);
    if cause == "terminated"
      @printf("Flipping line %d worked: %s -> %s!\n",
              flipip,
              inst, newinst)
      break
    end       
  end
      
  flipip += 1
end

@printf("CPU halted by: %s\n", cause)
print("Final CPU State: ")
cpuPrintState(cpu)

```

Final solution can be run from the command line as follows,

```
% julia soln_day08.jl --help
usage: soln_day08.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
