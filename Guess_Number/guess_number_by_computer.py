import random

# user put the number and the computer has to guess the number
# need a randomizter  for computer to get the input or to  the guess the number given by the user
user = input("Enter the number ")

if user.isdigit():
    user = int(user)

num = random.randrange(1, 7)

while num != user:
    print("Try again")
    # i have to call num  again  so the whole process can take  place again
    num = random.randrange(1, 7)
    if num == user:
        print("correct!")
        break
