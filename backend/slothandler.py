
from PySide6.QtCore import QObject, Slot, Signal

import pathlib, sys

class Slothandler(QObject):

    def __init__(self, app):
        super(Slothandler, self).__init__()
        self.app = app
    
    addLinkSignal = Signal(str, arguments=['linkName'])
    addFormEntrySignal = Signal(str, str, arguments=['header', 'type'])
    clearFormEntrySignal = Signal()
    addEntrySignal = Signal(str, arguments=['title'])
    focusEntrySignal = Signal(str, list, arguments=['entryHeader', 'values'])
    updateHeaderSignal = Signal(str, str, arguments=['oldVal', 'newVal'])
    clearHierarchySignal = Signal()

    @Slot(str)
    def navigate(self, nav_title):
        
        self.clearHierarchySignal.emit()
        self.app.reset_entries()
        self.app.currentLink = nav_title
        self.clearFormEntrySignal.emit()

        linkPage = self.app.data['links'][nav_title]
        for fieldHeader in linkPage['fieldHeaders']:
            self.addFormEntrySignal.emit(fieldHeader, linkPage[fieldHeader]['type'])
    
    @Slot()
    def add_entry(self):

        new_title = f'new{self.app.currentLink}'
        index = 0

        while f'{new_title}{index}' in self.app.entries['headers']:
            index += 1
        
        header = f'{new_title}{index}'
        self.app.entries['headers'].append(header)
        self.app.entries[header] = {
            'count': 0,
            'fieldHeaders': []
        }
        
        for field_header in self.app.data['links'][self.app.currentLink]['fieldHeaders']:
            self.app.entries[header]['count'] += 1
            self.app.entries[header]['fieldHeaders'].append(field_header)
            self.app.entries[header][field_header] = {
                'type': self.app.data['links'][self.app.currentLink][field_header]['type'],
                'value': self.app.data['links'][self.app.currentLink][field_header]['defaultValue']
            }
        
        self.addEntrySignal.emit(header)
    
    @Slot(str)
    def focus_entry(self, header):

        output = []

        for field_header in self.app.entries[header]['fieldHeaders']:
            if field_header == 'Title':
                output.append(header)
            else:
                output.append(self.app.entries[header][field_header]['value'])
        
        self.focusEntrySignal.emit(header, output)

    @Slot(str, str, str)
    def update_entry(self, header, field_header, value):

        if field_header == 'Title' and value != header and value not in self.app.entries[header]:
            for i in range(0, len(self.app.entries['headers'])):
                if self.app.entries['headers'][i] == header:
                    self.app.entries['headers'][i] = value
            self.app.entries[value] = self.app.entries[header]
            del(self.app.entries[header])
            self.app.entries[value][field_header]['value'] = value
            self.updateHeaderSignal.emit(header, value)
        elif field_header != 'Title':
            self.app.entries[header][field_header]['value'] = value



        



