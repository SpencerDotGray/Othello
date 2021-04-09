
from backend.slothandler import Slothandler
import random

class Controller:

    def __init__(self, app, slothandler):
        self.app = app
        self.slothandler = slothandler
    
    def place(self, row, col):
        self.slothandler.place(row, col)
    
    def can_place(self, row, col) -> bool:
        return self.slothandler.can_place(row, col)
    
    def is_game_over(self) -> bool:
        return self.slothandler.go
    
    def new_game(self):
        self.slothandler.new_game()
    
    def get_available_moves(self, board=None):

        def contains(one, two):
            for r, c in one:
                if r == two[0] and c == two[1]:
                    return True
            return False

        if board is None:
            self.slothandler.availableMovesSignal.emit()
            return self.slothandler.moves
        else:
            moves = []

            size = board.pop(0)
            placer = board.pop(0)

            for r in range(0, size):
                for c in range(0, size):
                    
                    index = r*size + c
                    adjacent = False

                    if board[index] == 0:

                        # Above
                        ci = (r-1)*size + c
                        if ci >= 0 and ci < size*size and board[ci] != placer:
                            i = r-1
                            while i >= 0:
                                if board[i*size+c] == 0:
                                    break
                                elif board[i*size+c] == placer:
                                    if not contains(moves, [r, c]):
                                        moves.append([r, c])
                                i -= 1
                        
                        # Below 
                        ci = (r+1)*size + c
                        if ci >= 0 and ci < size**2 and board[ci] != 0 and board[ci] != placer:
                            i = r+1
                            while i < size:
                                if board[i*size+c] == 0:
                                    break
                                elif board[i*size+c] == placer:
                                    if not contains(moves, [r, c]):
                                        moves.append([r, c])
                                i += 1
                        
                        # Left
                        ci = r*size + (c-1)
                        if ci >= 0 and ci < size**2 and board[ci] != 0 and board[ci] != placer:
                            j = c-1
                            while i >= 0:
                                if board[r*size+j] == 0:
                                    break
                                elif board[r*size+j] == placer:
                                    if not contains(moves, [r, c]):
                                        moves.append([r, c])
                                j -= 1
                        
                        # Right
                        ci = r*size + (c+1)
                        if ci >= 0 and ci < size**2 and board[ci] != 0 and board[ci] != placer:
                            j = c+1
                            while i >= 0:
                                if board[r*size+j] == 0:
                                    break
                                elif board[r*size+j] == placer:
                                    if not contains(moves, [r, c]):
                                        moves.append([r, c])
                                j += 1

                        # Top Left
                        i, j = (r-1, c-1)
                        if i*size+j >= 0 and i*size+j < size**2:
                            if board[i*size+j] == -1 * placer:
                                while (i >= 0 and j >= 0):
                                    if board[i*size+j] == 0:
                                        break
                                    elif board[i*size+j] == placer:
                                        if not contains(moves, [i, j]):
                                            print(f'Top Left: {j} {j}')
                                            moves.append([i, j])
                                    i -= 1
                                    j -= 1
                        
                        # Top Right
                        i, j = (r-1, c+1)
                        if i*size+j >= 0 and i*size+j < size**2:
                            if board[i*size+j] == -1 * placer:
                                while (i >= 0 and j < size):
                                    if board[i*size+j] == 0:
                                        break
                                    elif board[i*size+j] == placer:
                                        if not contains(moves, [i, j]):
                                            print(f'Top Right: {j} {j}')
                                            moves.append([i, j])
                                    i -= 1
                                    j += 1
                        
                        # Bottom Right
                        i, j = (r+1, c+1)
                        if i*size+j >= 0 and i*size+j < size**2:
                            if board[i*size+j] == -1 * placer:
                                while (i < size and j < size):
                                    if board[i*size+j] == 0:
                                        break
                                    elif board[i*size+j] == placer:
                                        if not contains(moves, [i, j]):
                                            print(f'Bottom Right: {i} {j}')
                                            moves.append([i, j])
                                    i += 1
                                    j += 1
                        
                        # Bottom Left
                        i, j = (r+1, c-1)
                        if i*size+j >= 0 and i*size+j < size**2:
                            if board[i*size+j] == -1 * placer:
                                while (i < size and j < size):
                                    if board[i*size+j] == 0:
                                        break
                                    elif board[i*size+j] == placer:
                                        if not contains(moves, [i, j]):
                                            print(f'Bottom Left: {j} {j}')
                                            moves.append([i, j])
                                    i += 1
                                    j -= 1

            return moves

    
    def _ai_random_move(self):
        moves = self.get_available_moves()
        if len(moves) == 0:
            return None
        return moves[random.randint(0, len(moves)-1)]
    

    def future_place(self, row, col, board=None):
        
        def contains(one, two):
            for r, c in one:
                if r == two[0] and c == two[1]:
                    return True
            return False

        if board is None:
            self.slothandler.getBoardSignal.emit()
            board = self.slothandler.board

        size = board.pop(0)
        placer = board.pop(0)

        if contains(self.get_available_moves(board=[size, placer]+board), [row, col]) and board[row*size+col] == 0:

            board[row*size+col] = placer

            # Above
            doFlip = False
            i = row-1
            while i >= 0:
                ci = i*size+col
                if board[ci] == 0:
                    break
                elif board[ci] == placer:
                    doFlip = True
                i -= 1
            if doFlip:
                i = row-1
                while i >= 0:
                    ci = i*size+col
                    if board[ci] != -1 * placer:
                        break
                    board[ci] = -1 * board[ci]
                    i -= 1
            
            # Below 
            doFlip = False
            i = row+1
            while i < size:
                ci = i*size+col
                if board[ci] == 0:
                    break
                elif board[ci] == placer:
                    doFlip = True
                i += 1
            if doFlip:
                i = row+1
                while i < size:
                    ci = i*size+col
                    if board[ci] != -1 * placer:
                        break
                    board[ci] = -1 * board[ci]
                    i += 1
            
            # Left 
            doFlip = False
            i = col-1
            while i >= 0:
                ci = row*size+i
                if board[ci] == 0:
                    break
                elif board[ci] == placer:
                    doFlip = True
                i -= 1
            if doFlip:
                i = col-1
                while i >= 0:
                    ci = row*size+i
                    if board[ci] != -1 * placer:
                        break
                    board[ci] = -1 * board[ci]
                    i -= 1
            
            # Right 
            doFlip = False
            i = col+1
            while i < size:
                ci = row*size+i
                if board[ci] == 0:
                    break
                elif board[ci] == placer:
                    doFlip = True
                i += 1
            if doFlip:
                i = col+1
                while i < size:
                    ci = row*size+i
                    if board[ci] != -1 * placer:
                        break
                    board[ci] = -1 * board[ci]
                    i += 1
            
            # Top Left
            doFlip = False
            i, j = (row-1, col-1)
            while i >= 0 and j >= 0:
                ci = i*size+j
                if board[ci] == placer:
                    doFlip = True
                i -= 1
                j -= 1
            if doFlip:
                i, j = (row-1, col-1)
                ci = i*size+j
                while i >= 0 and j >= 0 and board[ci] != placer:
                    board[ci] = -1 * board[ci]
                    i -= 1
                    j -= 1
            
            # Top Right
            doFlip = False
            i, j = (row-1, col+1)
            while i >= 0 and j < size:
                ci = i*size+j
                if board[ci] == placer:
                    doFlip = True
                i -= 1
                j += 1
            if doFlip:
                i, j = (row-1, col+1)
                ci = i*size+j
                while i >= 0 and j < size and board[ci] != placer:
                    board[ci] = -1 * board[ci]
                    i -= 1
                    j += 1
            
            # Bottom Right
            doFlip = False
            i, j = (row+1, col+1)
            while i < size and j < size:
                ci = i*size+j
                if board[ci] == placer:
                    doFlip = True
                i += 1
                j += 1
            if doFlip:
                i, j = (row+1, col+1)
                ci = i*size+j
                while i < size and j < size and board[ci] != placer:
                    board[ci] = -1 * board[ci]
                    i += 1
                    j += 1
            
            # Bottom Left
            doFlip = False
            i, j = (row+1, col-1)
            while i < size and j >= 0:
                ci = i*size+j
                if board[ci] == placer:
                    doFlip = True
                i += 1
                j -= 1
            if doFlip:
                i, j = (row+1, col-1)
                ci = i*size+j
                while i < size and j >= 0 and board[ci] != placer:
                    board[ci] = -1 * board[ci]
                    i += 1
                    j -= 1
            
            return [size, placer * -1] + board

        else:
            return -1
    
    def thing(self):
        board = self.future_place(3, 2)
        size = board.pop(0)
        placer = board.pop(0)
        for i in range(0, size):
            for j in range(0, size):
                piece = board[i*size+j]
                if len(piece.__str__()) == 2:
                    print(piece, end='')
                else:
                    print(f' {piece}', end='')
            print('')
        print(self.get_available_moves(board=[size, placer]+board))

        



