
from PySide6.QtCore import QObject, Slot, Signal

import pathlib, sys

class Slothandler(QObject):

    def __init__(self, app):
        super(Slothandler, self).__init__()
        self.app = app
        self.cp = None
    
    flipSignal = Signal(float, float, bool, arguments=['row', 'col', 'isWhite'])
    placeSignal = Signal(float, float, bool, arguments=['row', 'col', 'isWhite'])
    canPlaceSignal = Signal(float, float, bool, arguments=['row', 'col', 'isWhite'])
    newGameSignal = Signal()

    @Slot(float, float, bool)
    def can_place_piece(self, row, col, is_white) -> bool:
        self.canPlaceSignal.emit(row, col)
        result = self.cp
        self.cp = None
        return result
    
    @Slot(float, float, bool)
    def place(self, row, col, is_white) -> bool:
        self.canPlaceSignal.emit(row, col, is_white)
        if self.cp == False:
            self.cp = None
            return False
        else:
            print('placed')
            self.placeSignal.emit(row, col, is_white)

    
    @Slot(bool)
    def set_can_place(self, can_place):
        self.cp = can_place
    
    @Slot(float, float)
    def flip(self, row, col):
        self.flipSignal.emit(row, col)
    
    @Slot()
    def new_game(self):
        self.newGameSignal.emit()
    