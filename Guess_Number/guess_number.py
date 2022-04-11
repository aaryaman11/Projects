# take input from the user for the guess
# need to make a  randomizer of  numbers
# a condition when the user guessed the right number the program ends
# At the end it gives a message of you guessed the right number
import random

guess_input = input("Guess the number ")
# Random num = new Random()
min = 1
max = 6
y = random.randrange(1, 7)
if guess_input == y:
    print("You guessed the right number")
elif guess_input != y:
    guess_input = input("Guess the number ")
