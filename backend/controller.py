
from backend.slothandler import Slothandler

class Controller:

    def __init__(self, app, slothandler):
        self.app = app
        self.slothandler = slothandler
    
    def place(row, col):
        self.slothandler.place(row, col)
    
    def can_place(row, col) -> bool:
        return self.slothandler.can_place(row, col)
    
    def is_game_over() -> bool:
        return self.slothandler.go
