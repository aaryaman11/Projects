import random

# user put the number and the computer has to guess the number
# need a randomizter  for computer to get the input or to  the guess the number given by the user
# i can  make the program a little smarter by having high and low limits so the computer  can guess  quickly
user = input("Enter the number ")

if user.isdigit():
    user = int(user)
# adding the low and high for  range
low = 1
high = 7
num = random.randrange(low, high)

while num != user:
    print("Try again")
    # i have to call num  again  so the whole process can take  place again
    if num > user:
        high -= 1
    elif num < user:
        low += 1
    num = random.randrange(low, high)
    if num == user:
        print("correct!")
        break
