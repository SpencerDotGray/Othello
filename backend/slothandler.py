
from PySide6.QtCore import QObject, Slot, Signal

import pathlib, sys

class Slothandler(QObject):

    def __init__(self, app):
        super(Slothandler, self).__init__()
        self.app = app
        self.cp = None
        self.go = False
        self.moves = []
    
    flipSignal = Signal(float, float, arguments=['row', 'col'])
    placeSignal = Signal(float, float, arguments=['row', 'col'])
    canPlaceSignal = Signal(float, float, arguments=['row', 'col'])
    newGameSignal = Signal()
    availableMovesSignal = Signal()

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
        for move in moves:
            print(move)
    