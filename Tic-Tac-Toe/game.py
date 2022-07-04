# for the tic tac toe we need 3x3x3 board so we need to create that first
#from msilib.schema import Billboard

#from numpy import square
from player import human_player, computer_player


class TicTactoe:
    def __init__(self):
        # we will use a single list to rep 3x3 board
        self.board = ['' for _ in range(9)]
        self.current_winner = None  # keep track of winner

    def board(self):
        for row in [self.board[i*3:(i+1)*3] for i in range(3)]:
            print('| ' + ' | '.join(row) + ' |')

    @staticmethod
    def print_board_nums():
        # 0 | 1 | 2 etc (tells us what number corresponds what box)
        number_board = [[str(i) for i in range(j*3, (j+1)*3)]
                        for j in range(3)]
        for row in number_board:
            print('| ' + ' | '.join(row) + ' |')

    def available_moves(self):
        # return a list of indices
        # -----------------------------
        #moves = []
        # for (i, spot) in enumerate(self.board):
        # enumerate will make a list and assign the tuples that have the index and the value at that index
        # ['x', 'x', 'o'] -->  [(0,'x'), (1, 'x'), (2, 'o')]
        # if spot == ' ':
        #    moves.append(i)
        # return moves
        # ------------------------------
        # another way to write this block of code
        return [i for i, spot in enumerate(self.board) if spot == ' ']

    def empty_squares(self):
        return ' ' in self.board  # it would just become a boolean

    def num_empty_squares(self):
        return self.board.count(' ')

    def make_move(self, square,  letter):
        # if valid move make the move (assign square to letter)
        # then return true. if invalid return  false
        if self.board[square] == ' ':
            self.board[square] = letter
            if self.winner(square, letter):
                self.current_winner = letter
            return True
        return False

    # check for the winner
    def winner(self, square, letter):
        # winner if 3 in a row anywhere. we have to check all of these
        # first let's check the  row
        row_ind = square // 3
        row = self.board[row_ind*3:  (row_ind + 1) * 3]
        #  function returns: True - If all elements in an iterable are true
        if all([spot == letter for spot in row]):
            return True

        # check column
        col_ind = square % 3
        column = [self.board[col_ind+i*3] for i in range(3)]
        if all([spot == letter for spot in column]):
            return True

        # check diagonal
        # but only if the square is even number (0, 2, 4, 6, 8)
        # these are the only moves possible to win a diagonal
        if square % 2 == 0:
            diagonal1 = [self.board[i]
                         for i in [0, 4, 8]]  # left to right diagonal
            if all([spot == letter for spot in diagonal1]):
                return True
            diagonal2 = [self.board[i]
                         for i in [2, 4, 6]]  # right to left diagonal
            if all([spot == letter for spot in diagonal2]):
                return True

        # if all checks fail
        return False


def play(game, x_player, o_player,  print_game=True):
    # returns the winner of the game! and thr letter or None for a tie
    if print_game:
        game.print_board_nums()

    letter = 'X'  # starting letter
    # iterate while the game still has empty squares
    # we  don't have to worry about the winner because we will just return that which  will break the loop
    while game.empty_squares():
        # get the move from appropirate player
        if letter == 'O':
            square = o_player.get_move(game)
        else:
            square = x_player.get_move(game)

        # let's  define a function to make a move
        if game.make_move(square, letter):
            if print_game:
                print(letter + f' makes a move to square {square}')
                game.print_board()
                print('')  # empty line

            if game.current_winner:
                if print_game:
                    print(letter + ' wins!')
                return letter

            # after we made our move we need to alternate letter for other player's turn
            letter = 'O' if letter == 'X' else 'X'

        if print_game:
            print('It\'s a tie!')


if __name__ == ' __main__':
    x_player = human_player('X')
    o_player = computer_player('O')
    t = TicTactoe()
    play(t,  x_player, o_player, print_game=True)
