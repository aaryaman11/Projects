print("Welecome to the  Game!")

# taking the input from the user based on the question
user_input = input("Do you like to play? ")
# making condition to play the gaame
if user_input.lower() != "yes":
    quit()
print("okay time to play!")

# asking question and answers from the user
# keeping track of points for right and wrong answers

Question1 = input("What is the name of the disease for the recent pandemic? ")
Question2 = input("What is country  is  attacking Ukraine? ")
Question3 = input("Which company is famous for electric vehicles? ")

# making counter for right and wrong answer
right_answer = 0
wrong_answer = 0
if Question1.lower() == "covid19":
    right_answer += 1
    print("Correct!")
else:
    wrong_answer += 1
    print("Wrong!")
if Question2.lower() == "russia":
    right_answer += 1
    print("Correct!")
else:
    wrong_answer += 1
    print("Wrong!")
if Question3.lower() == "tesla":
    right_answer += 1
    print("Correct!")
else:
    wrong_answer += 1
    print("Wrong!")

if Question1.lower() == "covid19" and Question2.lower() == "russia" and Question3.lower() == "tesla":
    print("you got all the answers correct!")
else:
    print("You lost the game")


# condition statement based on the number of correct  answer to  use  "s" or not
if right_answer > 1:
    print("You got " + str(right_answer) + " correct answers")
else:
    print("You got " + str(right_answer) + " correct answer")

if wrong_answer > 1:
    print("You got " + str(wrong_answer) + " wrong answers")
else:
    print("You got " + str(wrong_answer) + " wrong answer")
