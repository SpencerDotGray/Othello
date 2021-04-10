
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
        elif board == -1:
            return []
        else:
            moves = []
            size = board[0]
            placer = board[1]
            b = board[2:]

            for r in range(0, size):
                for c in range(0, size):
                    
                    index = r*size + c
                    adjacent = False

                    if b[index] == 0:

                        # Above
                        ci = (r-1)*size + c
                        if ci >= 0 and ci < size*size and b[ci] != placer:
                            i = r-1
                            while i >= 0:
                                if b[i*size+c] == 0:
                                    break
                                elif b[i*size+c] == placer:
                                    if not contains(moves, [r, c]):
                                        moves.append([r, c])
                                i -= 1
                        
                        # Below 
                        ci = (r+1)*size + c
                        if ci >= 0 and ci < size**2 and b[ci] != 0 and b[ci] != placer:
                            i = r+1
                            while i < size:
                                if b[i*size+c] == 0:
                                    break
                                elif b[i*size+c] == placer:
                                    if not contains(moves, [r, c]):
                                        moves.append([r, c])
                                i += 1
                        
                        # Left
                        ci = r*size + (c-1)
                        if ci >= 0 and ci < size**2 and b[ci] != 0 and b[ci] != placer:
                            j = c-1
                            while i >= 0:
                                if b[r*size+j] == 0:
                                    break
                                elif b[r*size+j] == placer:
                                    if not contains(moves, [r, c]):
                                        moves.append([r, c])
                                j -= 1
                        
                        # Right
                        ci = r*size + (c+1)
                        if ci >= 0 and ci < size**2 and b[ci] != 0 and b[ci] != placer:
                            j = c+1
                            while i >= 0:
                                if b[r*size+j] == 0:
                                    break
                                elif b[r*size+j] == placer:
                                    if not contains(moves, [r, c]):
                                        moves.append([r, c])
                                j += 1

                        # Top Left
                        i, j = (r-1, c-1)
                        if i*size+j >= 0 and i*size+j < size**2:
                            if b[i*size+j] == -1 * placer:
                                while (i >= 0 and j >= 0):
                                    if b[i*size+j] == 0:
                                        break
                                    elif b[i*size+j] == placer:
                                        if not contains(moves, [r, c]):
                                            moves.append([r, c])
                                    i -= 1
                                    j -= 1
                        
                        # Top Right
                        i, j = (r-1, c+1)
                        if i*size+j >= 0 and i*size+j < size**2:
                            if b[i*size+j] == -1 * placer:
                                while (i >= 0 and j < size):
                                    if b[i*size+j] == 0:
                                        break
                                    elif b[i*size+j] == placer:
                                        if not contains(moves, [r, c]):
                                            moves.append([r, c])
                                    i -= 1
                                    j += 1
                        
                        # Bottom Right
                        i, j = (r+1, c+1)
                        if i*size+j >= 0 and i*size+j < size**2:
                            if b[i*size+j] == -1 * placer:
                                while (i < size and j < size):
                                    if b[i*size+j] == 0:
                                        break
                                    elif b[i*size+j] == placer:
                                        if not contains(moves, [r, c]):
                                            moves.append([r, c])
                                    i += 1
                                    j += 1
                        
                        # Bottom Left
                        i, j = (r+1, c-1)
                        if i*size+j >= 0 and i*size+j < size**2:
                            if b[i*size+j] == -1 * placer:
                                while (i < size and j < size):
                                    if b[i*size+j] == 0:
                                        break
                                    elif b[i*size+j] == placer:
                                        if not contains(moves, [r, c]):
                                            moves.append([r, c])
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

        size = board[0]
        placer = board[1]
        b = board[2:]

        if contains(self.get_available_moves(board=board), [row, col]) and b[row*size+col] == 0:

            b[row*size+col] = placer

            # Above
            doFlip = False
            i = row-1
            while i >= 0:
                ci = i*size+col
                if b[ci] == 0:
                    break
                elif b[ci] == placer:
                    doFlip = True
                i -= 1
            if doFlip:
                i = row-1
                while i >= 0:
                    ci = i*size+col
                    if b[ci] != -1 * placer:
                        break
                    b[ci] = -1 * b[ci]
                    i -= 1
            
            # Below 
            doFlip = False
            i = row+1
            while i < size:
                ci = i*size+col
                if b[ci] == 0:
                    break
                elif b[ci] == placer:
                    doFlip = True
                i += 1
            if doFlip:
                i = row+1
                while i < size:
                    ci = i*size+col
                    if b[ci] != -1 * placer:
                        break
                    b[ci] = -1 * b[ci]
                    i += 1
            
            # Left 
            doFlip = False
            i = col-1
            while i >= 0:
                ci = row*size+i
                if b[ci] == 0:
                    break
                elif b[ci] == placer:
                    doFlip = True
                i -= 1
            if doFlip:
                i = col-1
                while i >= 0:
                    ci = row*size+i
                    if b[ci] != -1 * placer:
                        break
                    b[ci] = -1 * b[ci]
                    i -= 1
            
            # Right 
            doFlip = False
            i = col+1
            while i < size:
                ci = row*size+i
                if b[ci] == 0:
                    break
                elif b[ci] == placer:
                    doFlip = True
                i += 1
            if doFlip:
                i = col+1
                while i < size:
                    ci = row*size+i
                    if b[ci] != -1 * placer:
                        break
                    b[ci] = -1 * b[ci]
                    i += 1
            
            # Top Left
            doFlip = False
            i, j = (row-1, col-1)
            while i >= 0 and j >= 0:
                ci = i*size+j
                if b[ci] == placer:
                    doFlip = True
                i -= 1
                j -= 1
            if doFlip:
                i, j = (row-1, col-1)
                ci = i*size+j
                while i >= 0 and j >= 0 and b[ci] != placer:
                    b[ci] = -1 * b[ci]
                    i -= 1
                    j -= 1
            
            # Top Right
            doFlip = False
            i, j = (row-1, col+1)
            while i >= 0 and j < size:
                ci = i*size+j
                if b[ci] == placer:
                    doFlip = True
                i -= 1
                j += 1
            if doFlip:
                i, j = (row-1, col+1)
                ci = i*size+j
                while i >= 0 and j < size and b[ci] != placer:
                    b[ci] = -1 * b[ci]
                    i -= 1
                    j += 1
            
            # Bottom Right
            doFlip = False
            i, j = (row+1, col+1)
            while i < size and j < size:
                ci = i*size+j
                if b[ci] == placer:
                    doFlip = True
                i += 1
                j += 1
            if doFlip:
                i, j = (row+1, col+1)
                ci = i*size+j
                while i < size and j < size and b[ci] != placer:
                    b[ci] = -1 * b[ci]
                    i += 1
                    j += 1
            
            # Bottom Left
            doFlip = False
            i, j = (row+1, col-1)
            while i < size and j >= 0:
                ci = i*size+j
                if b[ci] == placer:
                    doFlip = True
                i += 1
                j -= 1
            if doFlip:
                i, j = (row+1, col-1)
                ci = i*size+j
                while i < size and j >= 0 and b[ci] != placer:
                    b[ci] = -1 * b[ci]
                    i += 1
                    j -= 1
            
            temp = [size, (placer*-1)]
            temp.extend(b)
            return temp

        else:
            return -1

        



