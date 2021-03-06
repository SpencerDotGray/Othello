
from PySide6.QtCore import QObject, Slot, Signal

import pathlib
import sys
import time
import asyncio


class Slothandler(QObject):

    def __init__(self, app):
        super(Slothandler, self).__init__()
        self.app = app
        self.cp = None
        self.go = False
        self.moves = []
        self.board = []
        self.ai_level = 0
        self.player_turn = 0

    flipSignal = Signal(float, float, arguments=['row', 'col'])
    placeSignal = Signal(float, float, arguments=['row', 'col'])
    canPlaceSignal = Signal(float, float, arguments=['row', 'col'])
    newGameSignal = Signal()
    availableMovesSignal = Signal()
    getBoardSignal = Signal()
    foldSignal = Signal()

    @Slot(float, float)
    def can_place(self, row, col) -> bool:
        self.canPlaceSignal.emit(row, col)
        result = self.cp
        self.cp = None
        return result

    @Slot(float, float)
    def place(self, row, col) -> bool:
        self.canPlaceSignal.emit(row, col)
        if self.cp == False:
            self.cp = None
            return False
        else:
            self.placeSignal.emit(row, col)

    @Slot(bool)
    def set_can_place(self, can_place):
        self.cp = can_place

    @Slot(float, float)
    def flip(self, row, col):
        self.flipSignal.emit(row, col)

    @Slot()
    def new_game(self):
        self.newGameSignal.emit()
        self.go = False

    @Slot(bool)
    def game_over(self, didWhiteWin):
        self.go = True

    @Slot(list)
    def set_available_moves(self, moves):
        self.moves = moves

    @Slot(list)
    def set_board(self, board):
        self.board = board

    @Slot(str, str)
    def ai_move(self, ai_mode, playerTurn):

        if playerTurn == 'white':
            self.player_turn = 1
        elif playerTurn == 'black':
            self.player_turn = -1

        if ai_mode == 'AI - Easy':
            self.ai_level = 0
        elif ai_mode == 'AI - Medium':
            self.ai_level = 1
        elif ai_mode == 'AI - Hard':
            self.ai_level = 2
        elif ai_mode == 'AI - Random':
            self.ai_level = -1
        
        if self.ai_level != -1:
            move = self.app.controller._ai_next_move()
        else:
            move = self.app.controller._ai_random_move()

        if move is None:
            self.foldSignal.emit()
        else:
            self.place(move[0], move[1])
