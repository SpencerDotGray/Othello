
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

    property var isWhiteTurn: false
    property var isGameOver: false

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
                    app.place(row, col)
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

    Popup {
        id: popup
        x: 100
        y: 100
        width: 400
        height: 200
        modal: true
        focus: true
        closePolicy: Popup.NoAutoClose
        property var winText: 'test'

        ColumnLayout {
            
            anchors.fill: parent
            Text {
                text: popup.winText
                font.pixelSize: 50
                font.bold: true
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            Button {
                
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                contentItem: Text {
                    text: 'New Game'
                }
                onClicked: {
                    app.new_game()
                    popup.close()
                }
            }
        }
    }

    Connections {

        target: app

        function onFlipSignal(row, col) {

            var index = row * num_rows + col
            grid.children[index].children[1].flip()
        }

        function onPlaceSignal(row, col) {

            var index = row*num_rows + col
            piece.createObject(grid.children[index], {'width': grid.width/(num_rows*2), 'height': grid.height/(num_rows*2), 'isWhite': isWhiteTurn})
            grid.children[index].containsPiece = true

            for (var i = row-1; i >= 0; i--) {
                var checkIndex = i*num_rows + col
                if (!grid.children[checkIndex].containsPiece || grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                    break;
                app.flip(i, col)
            }
            for (var i = row+1; i < num_rows; i++) {
                var checkIndex = i*num_rows + col
                if (!grid.children[checkIndex].containsPiece || grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                    break;
                app.flip(i, col)
            }
            for (var i = col-1; i >= 0; i--) {
                var checkIndex = row*num_rows + i
                if (!grid.children[checkIndex].containsPiece || grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                    break;
                app.flip(row, i)
            }
            for (var i = col+1; i < num_rows; i++) {
                var checkIndex = row*num_rows + i
                if (!grid.children[checkIndex].containsPiece || grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                    break;
                app.flip(row, i)
            }

            var whiteCount = 0
            var blackCount = 0

            for (var i = 0; i < grid.children.length; i++) {

                var child = grid.children[i]

                if (child.containsPiece) {

                    if (child.children[1].isWhite)
                        whiteCount += 1
                    else
                        blackCount += 1
                }
            }

            if (whiteCount == 0 || blackCount == 0) {
                isGameOver = true
                popup.winText = whiteCount == 0 ? 'Black wins' : 'White wins'
                popup.open()
                app.game_over(whiteCount != 0)
            }

            isWhiteTurn = !isWhiteTurn
        }

        function onCanPlaceSignal(row, col) {
            
            var index = row*num_rows + col
            if (grid.children[index].containsPiece || isGameOver)
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
                            && grid.children[checkIndex].children[1].isWhite != isWhiteTurn) {
                                app.set_can_place(true)
                                return
                        }
                    }
                }

                app.set_can_place(false)
            }
        }

        function onNewGameSignal() {
            isWhiteTurn = false
            isGameOver = false
            define_new_board()
        }
    }
}
