# take input from the user for the guess
# need to make a  randomizer of  numbers
# a condition when the user guessed the right number the program ends
# At the end it gives a message of you guessed the right number
import random

guess_input = input("Guess the number ")
# Random num = new Random()

y = random.randrange(1, 7)
while guess_input != y:
    z = input("Try again! ")
    if z == y:
        print("you guessed the right  number")
        break
    # elif guess_input != y:
    #   print("Wrong number! Try again ")
