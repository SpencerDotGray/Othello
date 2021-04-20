
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
                            while j >= 0:
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
                            while j < size:
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

    def _ai_next_move(self):
        depth = self.get_ai_depth()
        moves = self.get_available_moves()

        if (len(moves) == 0):
            return None
        if (depth == 0):
            return moves[random.randint(0, len(moves) - 1)]

        targetValue = self.max_value(float('-inf'), float('inf'), depth)
        return targetValue[1]

    def max_value(self, alpha, beta, remainingDepth, board=None):
        v = float('-inf')
        optimalMove = None
        if (remainingDepth == 0):
            # return the heuristic at this board
            return (self.get_hueristic(board), 0)
        else:
            moves = self.get_available_moves(board)
            for move in moves:
                boardBranch = self.future_place(move[0], move[1], board)
                if boardBranch != -1:
                    value = self.min_value(
                        alpha, beta, remainingDepth - 1, boardBranch)[0]
                    if (value >= v):
                        v = value
                        optimalMove = move
                    if v >= beta:
                        return (v, move)
                    alpha = min(alpha, v)
            return (v, optimalMove)

    def min_value(self, alpha, beta, remainingDepth, board):
        v = float('inf')
        optimalMove = None
        if (remainingDepth == 0):
            return (self.get_hueristic(board), 0)
        else:
            moves = self.get_available_moves(board)
            for move in moves:
                boardBranch = self.future_place(move[0], move[1], board)
                value = self.max_value(
                    alpha, beta, remainingDepth - 1, boardBranch)[0]
                if (value <= v):
                    v = value
                    optimalMove = move
                if v <= alpha:
                    return (v, move)
                beta = min(beta, v)
            return (v, optimalMove)

    def get_stats(self, board):
        size, placer = board[0:2]
        b = board[2:]

        output = {
            'white': {
                'numMoves': 0,
                'flanked': 0,
                'edge': 0,
                'corner': 0,
                'inner': 0
            },
            'black': {
                'numMoves': 0,
                'flanked': 0,
                'edge': 0,
                'corner': 0,
                'inner': 0
            }
        }
        numMoves = len(self.get_available_moves())
        if self.get_ai_color() == 'black':
            output['black']['numMoves'] = numMoves
        else:
            output['white']['numMoves'] = numMoves


        for i in range(0, size):
            for j in range(0, size):

                index = i*size + j
                if b[index] == 0:
                    continue
                #count corners
                if (i == 0 and j == 0) or (i == size-1 and j == 0) or (i == size-1 and j == size-1) or (i == 0 and j == size-1):
                    if b[index] == 1:
                        output['white']['corner'] += 1
                    elif b[index] == -1:
                        output['black']['corner'] += 1
                #count edges
                elif i == 0 or j == 0 or i == size-1 or j == size-1:
                    if b[index] == 1:
                        output['white']['edge'] += 1
                    elif b[index] == -1:
                        output['black']['edge'] += 1
                else:
                    #count flanked pieces
                    isFlanked = False
                    for iChange in range(-1, 2):
                        for jChange in range(-1,2):
                            if b[( + iChange)*size + (j+jChange)] == 0:
                                isFlanked = True
                    if not isFlanked:
                        if b[index] == 1:
                            output['white']['flanked'] += 1
                        elif b[index] == -1:
                            output['black']['flanked'] += 1
                    #count inner pieces 
                    if b[index] == 1:
                        output['white']['inner'] += 1
                    elif b[index] == -1:
                        output['black']['inner'] += 1
                
        return output

    def get_hueristic(self, board):
        """
        this function returns a float representation of the goodness of the board in terms of the current player. Higher values are better
        """
        stats = self.get_stats(board)
        level = self.get_ai_level()
        aiColor = self.get_ai_color()
        # heuristic 1 returns totalBlackTiles/totalWhiteTiles
        if level == 0:
            whiteCount = 1 + stats['white']['edge'] + \
                stats['white']['inner'] + stats['white']['corner']
            blackCount = 1 + stats['black']['edge'] + \
                stats['black']['inner'] + stats['black']['corner']
            if aiColor == 'black':
                return blackCount
            else:
                return whiteCount
        if level == 1:
            # Static Weight Heuristic Function from 
            # (https://courses.cs.washington.edu/courses/cse573/04au/Project/mini1/RUSSIA/Final_Paper.pdf)*
            # *slightly modified
            scoreTable =[4, -3,  2,  2,  2,  2, -3,  4,
                        -3, -4, -1, -1, -1, -1, -4, -3, 
                        2,  -1,  1,  0,  0,  1, -1,  2,
                        2,  -1,  0,  1,  1,  0, -1,  2,
                        2,  -1,  0,  1,  1,  0, -1,  2,
                        2,  -1,  1,  0,  0,  1, -1,  2,
                        -3, -4, -1, -1, -1, -1, -4, -3,
                        4,  -3,  2,  2,  2,  2, -3,  4]
            size, placer = board[0:2]
            b = board[2:]

            heuristic = 0
            for i in range(0, size * size):
                if(aiColor == 'white'):
                    heuristic += b[i] * scoreTable[i]
                else:
                    heuristic += b[i] * scoreTable[i] * -1
            return heuristic
        if level == 2:
            mobilityWeight = 1
            flankWeight = 3
            edgeWeight = 5
            cornerWeight = 12
            whiteWeight=mobilityWeight * stats['white']['numMoves'] + \
                        flankWeight * stats['white']['flanked'] + \
                        edgeWeight * stats['white']['edge'] + \
                        cornerWeight * stats['white']['corner'] + \
                        stats['white']['inner'] + 1
                
            blackWeight=mobilityWeight * stats['black']['numMoves'] + \
                        flankWeight * stats['black']['flanked'] + \
                        edgeWeight * stats['black']['edge'] + \
                        cornerWeight * stats['black']['corner'] + \
                        stats['black']['inner'] + 1
            if aiColor == 'black':
                return (blackWeight / whiteWeight)
            else:
                return (whiteWeight / blackWeight)

    def get_ai_depth(self):
        """
        returns the depth that this level of ai should recurse to
        this function will return different values based on get_ai_level
        """
        level = self.get_ai_level()
        if level == 0:
            return 3
        if level == 1:
            return 4
        if level == 2:
            return 5

    def get_ai_level(self):
        """
        returns the hardness level of the ai. 0 is easy, 1 is medium, 2 is hard
        this function will be fixed when more levels are added
        """
        return self.slothandler.ai_level

    def get_ai_color(self):
        """
        this function returns 'white' if the ai is white and 'black' if the ai is black
        this function will be refactored once this information is exposed
        """

        if self.slothandler.player_turn == 1:
            return 'white'
        else:
            return "black"

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
