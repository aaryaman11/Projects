#from lib2to3.pytree import LeafPattern
import math
import random


class Player:
    def __init__(self, letter):
        # letter for x or o
        self.letter = letter

    #  next move for the players in the game

    def move(self, game):
        pass


class computer_player(Player):
    def __init__(self, letter):
        # about super class https://www.educative.io/edpresso/what-is-super-in-python
        super().__init__(letter)

        def move(self, game):
            # choicing a random spot on the game board
            square = random.choice(game.available_moves())
            return square


class human_player(Player):
    def __init__(self, letter):
        super().__init__(letter)

    def move(self, game):
        valid_square = False
        val = None
        while not valid_square:
            square = input(self.letter + '\'s turn. Input move (0-9):')
            # we are going to check that this is a correct value by trying to cast
            # it to an  integer, and if it's not, then we say it's invalid
            # if that spot is not available on the board, we also say it's invalid

            try:
                val = int(square)
                if val not in game.available_moves():
                    raise ValueError
                valid_square = True  # if the try is successful
            except ValueError:
                print('Invalid square. Try again.')

        return val
