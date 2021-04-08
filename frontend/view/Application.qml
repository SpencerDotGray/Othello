
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

ApplicationWindow {

    id: window  
    width: 600
    height: 600
    visible: true
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2.5 - height / 2.5

    property var isWhiteTurn: true

    header: ToolBar {
        RowLayout {
            anchors.fill: parent
            ToolButton {
                text: qsTr("New Game")
                onClicked: app.new_game()
            }
            Label {
                text: isWhiteTurn ? "White Turn" : "Black Turn"
                elide: Label.ElideRight
                horizontalAlignment: Qt.AlignHCenter
                verticalAlignment: Qt.AlignVCenter
                Layout.fillWidth: true
            }
        }
    }

    property int num_rows: 8

    function define_new_board() {
        grid.children = ''
        for (var i = 0; i < num_rows; i++) {
            for (var j = 0; j < num_rows; j++) {
                square.createObject(grid, {'width': grid.width/(num_rows+0.2), 'height': grid.height/(num_rows+0.2), 'row': i, 'col': j})
            }
        }
        piece.createObject(grid.children[27], {'width': grid.width/(num_rows*2), 'height': grid.height/(num_rows*2), 'isWhite': true})
        piece.createObject(grid.children[28], {'width': grid.width/(num_rows*2), 'height': grid.height/(num_rows*2), 'isWhite': false})
        piece.createObject(grid.children[35], {'width': grid.width/(num_rows*2), 'height': grid.height/(num_rows*2), 'isWhite': false})
        piece.createObject(grid.children[36], {'width': grid.width/(num_rows*2), 'height': grid.height/(num_rows*2), 'isWhite': true})
        grid.children[27].containsPiece = true
        grid.children[28].containsPiece = true
        grid.children[35].containsPiece = true
        grid.children[36].containsPiece = true
    }

    Component.onCompleted: {
        define_new_board()
    }

    Rectangle {
        anchors.fill: parent
        color: 'slategrey'
        GridLayout {

            anchors.fill: parent

            id: grid
            columns: num_rows
            columnSpacing: 2.15
            rowSpacing: 2.15
        }
    }

    Component {
        id: square
        Rectangle {

            color: 'white'
            border.color: '#fefefa'
            border.width: 0.5
            property var containsPiece: false
            property var row: -1
            property var col: -1

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    app.place(row, col, isWhiteTurn)
                }
            }
        }
    }

    Component {
        id: piece
        Rectangle {

            property var isWhite: true
            anchors.centerIn: parent
            radius: width/2
            color: isWhite ? 'white' : 'black'
            border.color: isWhite ? 'darkslategrey' : '#fefefa'
            border.width: 2

            function flip() {
                isWhite = !isWhite
            }
        }
    }

    Connections {

        target: app

        function onFlipSignal(row, col) {

            var index = row * num_rows + col
            grid.children[index].children[1].flip()
        }

        function onPlaceSignal(row, col, isWhite) {

            var index = row*num_rows + col
            piece.createObject(grid.children[index], {'width': grid.width/(num_rows*2), 'height': grid.height/(num_rows*2), 'isWhite': isWhite})
            grid.children[index].containsPiece = true
            isWhiteTurn = !isWhiteTurn

            
        }

        function onCanPlaceSignal(row, col, isWhite) {
            
            var index = row*num_rows + col
            if (grid.children[index].containsPiece || isWhiteTurn != isWhite)
                app.set_can_place(false)
            else {
                
                var checks = [
                    {'id': 'above', 'row': row-1, 'col': col },
                    {'id': 'below', 'row': row+1, 'col': col },
                    {'id': 'right', 'row': row, 'col': col+1 },
                    {'id': 'left', 'row': row, 'col': col-1 }
                ]

                for (var i = 0; i < checks.length; i++) {
                    var checkIndex = checks[i].row * num_rows + checks[i].col
                    if (checkIndex >= 0 && checkIndex < num_rows*num_rows) {
                        if (grid.children[checkIndex].containsPiece
                            && grid.children[checkIndex].children[1].isWhite != isWhite) {
                                app.set_can_place(true)
                                return
                        }
                    }
                }

                app.set_can_place(false)
            }
        }

        function onNewGameSignal() {
            define_new_board()
        }
    }
}
