user = input("Type your name: ")
print("Welecome to the adventure " + user)

response = input(
    "You are in a maze and you have to choose to either go left or right: ").lower()

if response == "left":
    response = input(
        "You arrived at a river, and either you swim through it or you walk around: ").lower()
    if response == "swim":
        print("you swam acrross, and have to save your life from piranha")
    elif response == "walk":
        print("you walked, but woke up an angry bear")
    else:
        print("You are out of the adventure!")
elif response == "right":
    response = input(
        "You found a spaceship, and you can either fly it or go ahead towards the mountain: ").lower()
    if response == "fly":
        print("The autopilot of the ship has taken you to another planet for another adventure")
    elif response == "mountain":
        response = input(
            "You meet an old woman, whose asking for your help: ").lower()
        if response == "yes":
            print("The old lady gives you reward, and you win.")
        elif response == "no":
            print("You didn't help the lady and lost the game.")
        else:
            print("You are out of the adventure!")
    else:
        print("You are out of the adventure!")
else:
    print("You are out of the adventure!")

print("Hope you enjoyed the adventure " + user)
