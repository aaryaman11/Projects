import random


# need a user input
# keep traack of scores of computer and user
# have to make conditions

user_wins = 0
computer_wins = 0


while user_wins != 3 and computer_wins != 3:
    user = input("Type Rock, Paper or Scissor: ").lower()
    computer = random.randint(0, 2)
    choices = ["rock", "paper", "scissor"]
    # rock = 0: paper = 1: scissor = 2:
    computer_pick = choices[computer]
    if user == "q":
        break
    if user == "rock" and computer_pick == "paper":
        print("You lost this round ")
        computer_wins += 1
        continue
    elif user == "rock" and computer_pick == "scissor":
        print("You won this round ")
        user_wins += 1
        continue
    elif user == "paper" and computer_pick == "scissor":
        print("You lost this round ")
        computer_wins += 1
        continue
    elif user == "paper" and computer_pick == "rock":
        print("You won this round ")
        user_wins += 1
        continue
    elif user == "scissor" and computer_pick == "rock":
        print("You lost this round ")
        computer_wins += 1
        continue
    elif user == "scissor" and computer_pick == "paper":
        print("You won this round ")
        user_wins += 1
    else:
        print("Draw. Try again!")
        continue

print("Game Over!")
