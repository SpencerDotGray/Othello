
from backend.slothandler import Slothandler
from backend.controller import Controller
import pathlib, json

class Application():

    def __init__(self, engine):
        self.engine = engine
        self.slothandler = Slothandler(self)
        self.controller = Controller(self, self.slothandler)
