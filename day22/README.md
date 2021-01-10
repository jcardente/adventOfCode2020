# Day 22 Solutions

[Day 22](https://adventofcode.com/2020/day/22) involved simulating 
a card game with a crab. 

The puzzle input was a deck of cards for two players,

```
Player 1:
9
2
6
3
1

Player 2:
5
8
4
7
10
```

In my solution, each player's deck was stored as an array of integers.

In part 1, the game consisted of a series of rounds in which,

- Each player draws the top card from their decks
- The player with the higher card take both cards and place
  them at the bottom of their deck
  
The game ended when a player had all of the cards.

Solving part 1 was simply a matter of implementing the rules
and simulating the game,

```julia
function playGameP1(d1, d2) 
  rounds = 0
  while ((length(d1) > 0) && (length(d2) > 0))
    c1 = d1[1]
    c2 = d2[1]
    
    d1 = d1[2:end]  
    d2 = d2[2:end]
    
    if c1 > c2
      d1 = vcat(d1, [c1, c2])
    else
      d2 = vcat(d2, [c2, c1])
    end

    rounds += 1
  end
  
  winner = length(d1) > 0 ? 1 : 2
  
  return winner, d1, d2
end
```

Part 2 added a recursive games with following rules,

- If the player deck contents occurred in a prior round of the current
  game, the game ends and player 1 wins
- Otherwise, players draw their top cards and,
    - If the value of both players' cards are equal to or greater than the
      number of cards in thier deck, a sub-game is started. The winner of the
      sub-game wins the round
    - Otherwise, the player with the higher card wins the round, takes the two
      cards, and adds them to the bottom of their deck
- As before, a game ends when a player no longer has any cards in their deck
      
Sub-games are played by each player taking the first N cards remaining
on their deck, where the number N is equal to the value of the card
in the parent game.

As for part 1, solving this part of the puzzle was really just a matter of 
implementing the rules, 

```julia
function playGameP2(d1, d2)
  # cache to hold previous hands
  seenHands = Set{String}()

  rounds     = 0
  gameWinner = 0
  while ((length(d1) > 0) && (length(d2) > 0))

    handsig = handSignature(d1,d2)
    if handsig in seenHands
      # if decks match prior round, player 1 wins
      # the GAME
      gameWinner = 1
      break
    end
    push!(seenHands, handsig)
    
    # draw cards
    c1 = d1[1]
    c2 = d2[1]
    d1 = d1[2:end]  
    d2 = d2[2:end]

    roundWinner = 0
    if (c1 <= length(d1) && c2 <= length(d2))
      # if both top cards less or equal to deck
      # size, ROUND winner is winner of recurse
      # game
      #
      # NB - pass top N of deck to the recursive
      #      game where N is the card drawn
      rd1 = deepcopy(d1[1:c1])
      rd2 = deepcopy(d2[1:c2])
      roundWinner, _, _ = playGameP2(rd1, rd2)
      
    else
      # Otherwise, ROUND winner is the player with
      # higher value card
      if c1 > c2
        roundWinner = 1
      else
        roundWinner = 2
      end
    end
    
    # Round winner get's cards added to their deck
    if roundWinner == 1
      d1 = vcat(d1, [c1, c2])
      
    elseif roundWinner == 2
      d2 = vcat(d2, [c2, c1])
    else
      error("No winner in round\n")
    end

    rounds += 1
  end

  if gameWinner == 0
    if (length(d1) > 0) && (length(d2) == 0)
      gameWinner = 1
      
    elseif (length(d1) == 0) && (length(d2) > 0)
      gameWinner = 2
      
    else
      error("Unknown game winner\n")
    end
  end

  return gameWinner, d1, d2
end
```

Final solution can be run from the command line,

```
% julia soln_day22.jl -h
usage: soln_day22.jl [-h] input part

positional arguments:
  input       Input file
  part        Part to solve, part1 or part2

optional arguments:
  -h, --help  show this help message and exit
```
