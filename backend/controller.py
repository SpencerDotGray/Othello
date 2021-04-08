
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
    
    def get_available_moves(self):
        self.slothandler.availableMovesSignal.emit()
        return self.slothandler.moves
    
    def _ai_random_move(self):
        moves = self.get_available_moves()
        move = moves[random.randint(0, len(moves)-1)]

    
    def get_available_moves_with_place(row, col):
        self.
