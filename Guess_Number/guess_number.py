# take input from the user for the guess
# need to make a  randomizer of  numbers
# a condition when the user guessed the right number the program ends
# At the end it gives a message of you guessed the right number
# let the user know how many chances they are  left with or in the beginning tell them u have 3 chances
import random

guess_input = input("Guess the number ")


# Random num = new Random()

# converting string to digit

if guess_input.isdigit():
    guess_input = int(guess_input)


y = random.randrange(1, 7)

# number of times a person can guess
guess_chances = 0
guess_chances += 1

while guess_input != y:
    z = input("Try again! ")
    guess_chances += 1

    # converting string to digit  or int
    if z.isdigit():
        z = int(z)
    if z == y:
        print("you guessed the right  number")
        break
    elif guess_chances == 3:
        print("You are out of chances! ")
        break
