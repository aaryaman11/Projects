from Words import words
import random
import string


def valid_words(words):
    # random selection of words from the list
    word = random.choice(words)
    while '-' in word or ' ' in word:
        word = random.choice(words)
    return word.upper()

# need to keep track which letters haven been guessed
# Also which letters are correctly guessed


def hangman():
    word = valid_words(words)
    word_letters = set(word)  # tracking which words have been guessed
    # list of uppercase  characterrs in english  dictionary
    alphabet = set(string.ascii_uppercase)
    guessed_letters = set()

    # keep track of the letters being used for the user

    while len(word_letters) > 0:
        # important to avoid showing just set() like  this --> You  have used letters:  set().
        # Use the .join method for print than f string method
        print(f'You  have used letters: {guessed_letters}')

        # words which are guessed and it also shows what more needs to be guessed (ie W - - A)
        word_list = [
            letter if letter in guessed_letters else '-' for letter in word]
        # to not to  show  the words in actual list format ie [] use .join method for the print statement rather than f string
        print('Current word:', ' ' .join(word_list))
        user_guessed = input("Type a letter: ").upper()
        # user_guessed in alphabet but not in guessed_letters  that what the if statement  means
        if user_guessed in alphabet - guessed_letters:
            guessed_letters.add(user_guessed)
            if user_guessed in word_letters:
                word_letters.remove(user_guessed)
        elif user_guessed in guessed_letters:
            print("you have already used this word. ")
        else:
            print("Please try again. ")
    return "You have won the game!"


#user_input = input("Type Something: ")
print(hangman())
