
from backend.slothandler import Slothandler
import pathlib, json

class Application():

    def __init__(self, engine):
        self.engine = engine
        self.slot_handler = Slothandler(self)
        self.data = {}
        with open(f'{pathlib.Path().absolute()}/backend/data/data.json') as file_in:
            self.data = json.load(file_in)
        self.entries = {
            'count': 0,
            'headers': []
        }
        self.currentLink = None
    
    def load(self):
        for link_header in self.data['links']['headers']:
            self.slot_handler.addLinkSignal.emit(self.data['links'][link_header]['title'])
    
    def reset_entries(self):
        self.entries = {
            'count': 0,
            'headers': []
        }
