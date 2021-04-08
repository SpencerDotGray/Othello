
from backend.slothandler import Slothandler
import pathlib, json

class Application():

    def __init__(self, engine):
        self.engine = engine
        self.slot_handler = Slothandler(self)
