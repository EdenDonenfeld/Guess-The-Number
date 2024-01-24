# Guess-The-Number
x86 assembly language game - guessing a number, including graphics and sound.

The goal of the game is to guess a number from 1 to 255 that the computer randomly chose, up to ten attempts.

After each round, a score is calculated.

The smaller the number of guesses, the higher the score.


# Running the code

Write these following lines in DOSBox in your local TASM folder.

1. mount c c:\tasm
2. c:
3. tasm game.asm
4. tlink game.obj
5. game.exe

