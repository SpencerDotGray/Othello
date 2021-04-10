
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

ApplicationWindow {

    id: window  
    width: 1006
    height: 620
    visible: true
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2.5 - height / 2.5

    property var isWhiteTurn: false
    property var isGameOver: false
    property var numWhite: 0
    property var numBlack: 0
    property var skippedTurn: false

    function aiCheck() {

        if (!isGameOver) {
            if (getAvailableMoves().length == 0) {

                if (skippedTurn) {
                    isGameOver = true
                    if (numWhite == numBlack) {
                        popup.winText = "No Moves Remaining\nDraw"
                        popup.open()
                    } else {
                        popup.winText = numWhite > numBlack ? 'No Moves Remaining\nWhite Wins' : 'No Moves Remaining\nBlack Wins'
                        popup.open()
                    }
                    skippedTurn = false
                } else {
                    isWhiteTurn = !isWhiteTurn
                    skippedTurn = true
                    aiCheck()
                }
            } else {
                skippedTurn == false

                if (isWhiteTurn && whiteComboBox.currentText != 'Player') {
                    app.ai_move(whiteComboBox.currentText)
                } else if (!isWhiteTurn && blackComboBox.currentText != 'Player') {
                    app.ai_move(blackComboBox.currentText)
                }
            }
        }
    }

    function isBoardFull() {
        for (var i = 0; i < num_rows*num_rows; i++) {
            if (!grid.children[i].containsPiece)
                return false
        }
        return true
    }

    onIsWhiteTurnChanged: aiCheck()

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
        numWhite = 2
        numBlack = 2
    }

    function count() {

        numWhite = 0
        numBlack = 0
        for (var i = 0; i < grid.children.length; i++) {

            var child = grid.children[i]

            if (child.containsPiece) {
                if (child.children[1].isWhite)
                    numWhite += 1
                else
                    numBlack += 1
            }
        }
    }

    Component.onCompleted: {
        define_new_board()
    }

    RowLayout {

        width: parent.width
        height: parent.height
        spacing: 0

        Rectangle {
            width: 200
            Layout.fillHeight: true
            color: "#f7f3e9"

            id: whiteSide

            ColumnLayout {
                
                width: parent.width
                height: parent.height - 20
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 10
                }

                Text {
                    text: isWhiteTurn ? 'White Turn [X]' : 'White Turn [ ]'
                    font.bold: true
                    font.family: 'Courier'
                    font.pixelSize: 22
                    color: 'darkslategrey'
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    height: 1
                    width: parent.width * 0.85
                    Layout.alignment: Qt.AlignHCenter
                    color: 'darkslategrey'
                }

                Text {
                    text: "Count: " + numWhite
                    font.pixelSize: 18
                    font.bold: true
                    color: 'darkslategrey'
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    width: parent.width * 0.85
                    color: 'white'
                    border.color: 'darkslategrey'
                    border.width: 2
                    radius: width * 0.05

                    Text {
                        id: whiteHistoryLabel
                        text: 'History'
                        font.pixelSize: 18
                        color: 'darkslategrey'
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                            topMargin: 10
                        }
                    }
                    Rectangle {
                        id: whiteHistoryDiv
                        width: parent.width * 0.85
                        height: 1
                        color: 'darkslategrey'
                        anchors {
                            top: whiteHistoryLabel.bottom
                            topMargin: 2.5
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                    ScrollView {
                        
                        width: parent.width
                        height: parent.height - whiteHistoryLabel.height - whiteHistoryDiv.height - 5 - 10
                        contentHeight: whiteHistoryContainer.height + 10
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: whiteHistoryDiv.bottom
                            topMargin: 2.5
                        }

                        ColumnLayout {
                            id: whiteHistoryContainer
                            width: parent.width
                        }
                    }
                }

                ComboBox {
                    id: whiteComboBox
                    model: ['Player', 'AI - Easy']
                    Layout.alignment: Qt.AlignHCenter
                    onActivated: aiCheck()
                }

                Button {
                    text: whiteComboBox.currentIndex != 0 ? qsTr('New Game') : qsTr('Resign')
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        if (text == 'New Game') {
                            whiteComboBox.currentIndex = 0
                            blackComboBox.currentIndex = 0
                            app.new_game()
                            popup.close()
                        } else {
                            app.game_over(!isWhiteTurn)
                            popup.winText = 'White Resigns'
                            popup.open()
                        }
                    }
                }
            }            
        }

        Rectangle { width: 4; color: 'darkslategrey'; Layout.fillHeight: true}

        Rectangle {
            width: 600
            Layout.fillHeight: true
            color: 'darkslategrey'
            GridLayout {

                anchors.fill: parent
                id: grid
                columns: num_rows
                columnSpacing: 2.15
                rowSpacing: 2.15
            }
        }

        Rectangle { width: 4; color: 'darkslategrey'; Layout.fillHeight: true }

        Rectangle {
            width: 200
            Layout.fillHeight: true
            color: "#f7f3e9"

            id: blackSide

            ColumnLayout {
                
                width: parent.width
                height: parent.height - 20
                anchors {
                    horizontalCenter: parent.horizontalCenter
                    top: parent.top
                    topMargin: 10
                }
                
                Text {
                    text: !isWhiteTurn ? 'Black Turn [X]' : 'Black Turn [ ]'
                    font.bold: true
                    font.family: 'Courier'
                    font.pixelSize: 22
                    color: 'darkslategrey'
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    height: 1
                    width: parent.width * 0.85
                    Layout.alignment: Qt.AlignHCenter
                    color: 'darkslategrey'
                }

                Text {
                    text: "Count: " + numBlack
                    font.bold: true
                    font.pixelSize: 18
                    color: 'darkslategrey'
                    Layout.alignment: Qt.AlignHCenter
                }

                Rectangle {
                    Layout.fillHeight: true
                    Layout.alignment: Qt.AlignHCenter
                    width: parent.width * 0.85
                    color: 'white'
                    border.color: 'darkslategrey'
                    border.width: 2
                    radius: width * 0.05

                    Text {
                        id: blackHistoryLabel
                        text: 'History'
                        font.pixelSize: 18
                        color: 'darkslategrey'
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: parent.top
                            topMargin: 10
                        }
                    }
                    Rectangle {
                        id: blackHistoryDiv
                        width: parent.width * 0.85
                        height: 1
                        color: 'darkslategrey'
                        anchors {
                            top: blackHistoryLabel.bottom
                            topMargin: 2.5
                            horizontalCenter: parent.horizontalCenter
                        }
                    }
                    ScrollView {
                        
                        width: parent.width
                        height: parent.height - blackHistoryLabel.height - blackHistoryDiv.height - 5 - 10
                        contentHeight: blackHistoryContainer.height + 10
                        anchors {
                            horizontalCenter: parent.horizontalCenter
                            top: blackHistoryDiv.bottom
                            topMargin: 2.5
                        }

                        ColumnLayout {
                            id: blackHistoryContainer
                            width: parent.width
                        }
                    }
                }

                ComboBox {
                    id: blackComboBox
                    model: ['Player', 'AI - Easy']
                    Layout.alignment: Qt.AlignHCenter
                    onActivated: aiCheck()
                }


                Button {
                    text: blackComboBox.currentIndex != 0 ? qsTr('New Game') : qsTr('Resign')
                    Layout.alignment: Qt.AlignHCenter
                    onClicked: {
                        if (text == 'New Game') {
                            whiteComboBox.currentIndex = 0
                            blackComboBox.currentIndex = 0
                            app.new_game()
                            popup.close()
                        } else {
                            app.game_over(!isWhiteTurn)
                            popup.winText = 'Black Resigns'
                            popup.open()
                        }
                    }
                }
                
            }            
        }
    }

    Component {
        id: historyEntry
        Rectangle {
            property var text: ''
            width: parent == null ? 0 : parent.width
            height: entryText.height
            color: 'transparent'
            Text {
                id: entryText
                text: parent.text
                font.pixelSize: 16
                color: 'darkslategrey'
                anchors.horizontalCenter: parent.horizontalCenter
            }
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
            border.color: isWhite ? 'black' : '#fefefa'
            border.width: 2

            function flip() {
                isWhite = !isWhite
            }
        }
    }

    Popup {
        id: popup
        anchors.centerIn: parent
        width: 650
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
                color: 'darkslategrey'
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                Button {
                    
                    contentItem: Text {
                        text: 'New Game'
                        color: 'darkslategrey'
                    }
                    onClicked: {
                        whiteComboBox.currentIndex = 0
                        blackComboBox.currentIndex = 0
                        app.new_game()
                        popup.close()
                    }
                }
                Button {
                    
                    contentItem: Text {
                        text: 'Show Board'
                        color: 'darkslategrey'
                    }
                    onClicked: {
                        popup.close()
                    }
                }
                Button {
                    
                    contentItem: Text {
                        text: 'Play Again (Same Player Types)'
                        color: 'darkslategrey'
                    }
                    onClicked: {
                        app.new_game()
                        popup.close()
                    }
                }
            }
        }
    }

    function contains(list, check) {

        for (var i = 0; i < list.length; i++) {
            if (list[i][0] == check[0] && list[i][1] == check[1]) {
                return true
            }
        }
        return false
    }

    function getAvailableMoves() {

        var moves = []

        for (var row = 0; row < num_rows; row++) {
            for (var col = 0; col < num_rows; col++) {
                var index = row*num_rows + col
                var adjacent = false
                if (!(grid.children[index].containsPiece || isGameOver)) {

                    // Above
                    var checkIndex = (row-1)*num_rows + col
                    if (checkIndex >= 0 && checkIndex < num_rows*num_rows && grid.children[checkIndex].containsPiece
                        && grid.children[checkIndex].children[1].isWhite != isWhiteTurn) {
                        
                        adjacent = true
                        for (var i = row-1; i >= 0; i--) {
                            if (!grid.children[(i)*num_rows+col].containsPiece)
                                break
                            else if (grid.children[(i)*num_rows+col].children[1].isWhite == isWhiteTurn) {
                                if (!contains(moves, [row, col]))
                                    moves.push([row, col])
                            }
                        }
                    }

                    // Below
                    checkIndex = (row+1)*num_rows + col
                    if (checkIndex >= 0 && checkIndex < num_rows*num_rows && grid.children[checkIndex].containsPiece
                        && grid.children[checkIndex].children[1].isWhite != isWhiteTurn) {
                        
                        adjacent = true
                        for (var i = row+1; i < num_rows; i++) {
                            if (!grid.children[(i)*num_rows+col].containsPiece)
                                break
                            else if (grid.children[(i)*num_rows+col].children[1].isWhite == isWhiteTurn) {
                                if (!contains(moves, [row, col]))
                                    moves.push([row, col])
                            }
                        }
                    }

                    // Left
                    checkIndex = row*num_rows + (col-1)
                    if (checkIndex >= 0 && checkIndex < num_rows*num_rows && grid.children[checkIndex].containsPiece
                        && grid.children[checkIndex].children[1].isWhite != isWhiteTurn) {
                        
                        adjacent = true
                        for (var i = col-1; i >= 0; i--) {
                            if (!grid.children[row*num_rows + i].containsPiece)
                                break
                            else if (grid.children[row*num_rows + i].children[1].isWhite == isWhiteTurn) {
                                if (!contains(moves, [row, col]))
                                    moves.push([row, col])
                            }
                        }
                    }

                    // Right
                    checkIndex = row*num_rows + (col+1)
                    if (checkIndex >= 0 && checkIndex < num_rows*num_rows && grid.children[checkIndex].containsPiece
                        && grid.children[checkIndex].children[1].isWhite != isWhiteTurn) {
                        
                        adjacent = true
                        for (var i = col+1; i < num_rows; i++) {
                            if (!grid.children[row*num_rows + i].containsPiece)
                                break
                            else if (grid.children[row*num_rows + i].children[1].isWhite == isWhiteTurn) {
                                if (!contains(moves, [row, col]))
                                    moves.push([row, col])
                            }
                        }
                    }

                    // Top Left
                    var i = row-1
                    var j = col-1
                    if (i*num_rows+j >= 0 && i*num_rows+j < num_rows*num_rows) {
                        var child = grid.children[i*num_rows + j]
                        if (child.containsPiece && child.children[1].isWhite != isWhiteTurn) {
                            while (i >= 0 && j >= 0) {
                                
                                child = grid.children[i*num_rows + j]
                                if (child.containsPiece && child.children[1].isWhite == isWhiteTurn)
                                    if (!contains(moves, [row, col]))
                                        moves.push([row, col])
                                else if (!child.containsPiece)
                                    break

                                i--
                                j--
                            }
                        }
                    }

                    // Bottom Right
                    var i = row+1
                    var j = col+1
                    if (i*num_rows+j >= 0 && i*num_rows+j < num_rows*num_rows) {
                        var child = grid.children[i*num_rows + j]
                        if (child.containsPiece && child.children[1].isWhite != isWhiteTurn) {
                            while (i < num_rows && j < num_rows) {
                                
                                child = grid.children[i*num_rows + j]
                                if (child.containsPiece && child.children[1].isWhite == isWhiteTurn)
                                    if (!contains(moves, [row, col]))
                                        moves.push([row, col])
                                else if (!child.containsPiece)
                                    break

                                i++
                                j++
                            }
                        }
                    }

                    // Top Right
                    var i = row-1
                    var j = col+1
                    if (i*num_rows+j >= 0 && i*num_rows+j < num_rows*num_rows) {
                        var child = grid.children[i*num_rows + j]
                        if (child.containsPiece && child.children[1].isWhite != isWhiteTurn) {
                            while (i >= 0 && j < num_rows) {
                                
                                child = grid.children[i*num_rows + j]
                                if (child.containsPiece && child.children[1].isWhite == isWhiteTurn)
                                    if (!contains(moves, [row, col]))
                                        moves.push([row, col])
                                else if (!child.containsPiece)
                                    break

                                i--
                                j++
                            }
                        }
                    }

                    // Bottom Left
                    var i = row+1
                    var j = col-1
                    if (i*num_rows+j >= 0 && i*num_rows+j < num_rows*num_rows) {
                        var child = grid.children[i*num_rows + j]
                        if (child.containsPiece && child.children[1].isWhite != isWhiteTurn) {
                            while (i < num_rows && j >= 0) {
                                
                                child = grid.children[i*num_rows + j]
                                if (child.containsPiece && child.children[1].isWhite == isWhiteTurn)
                                    if (!contains(moves, [row, col]))
                                        moves.push([row, col])
                                else if (!child.containsPiece)
                                    break

                                i++
                                j--
                            }
                        }
                    }
                }
            }
        }

        return moves
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
            
            if (isWhiteTurn) {
                historyEntry.createObject(whiteHistoryContainer, {'text': (row + ', ' + col)})
            } else {
                historyEntry.createObject(blackHistoryContainer, {'text': (row + ', ' + col)})
            }

            // Above
            var doFlip = false
            for (var i = row-1; i >= 0; i--) {
                var checkIndex = i*num_rows + col
                if (grid.children[checkIndex].containsPiece && grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                    doFlip = true
                if (!grid.children[checkIndex].containsPiece)
                    break
            }
            if (doFlip) {
                for (var i = row-1; i >= 0; i--) {
                    var checkIndex = i*num_rows + col
                    if (!grid.children[checkIndex].containsPiece || grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                        break;
                    app.flip(i, col)
                }
            }

            // Below
            var doFlip = false
            for (var i = row+1; i < num_rows; i++) {
                var checkIndex = i*num_rows + col
                if (grid.children[checkIndex].containsPiece && grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                    doFlip = true
                if (!grid.children[checkIndex].containsPiece)
                    break
            }
            if (doFlip) {
                for (var i = row+1; i < num_rows; i++) {
                    var checkIndex = i*num_rows + col
                    if (!grid.children[checkIndex].containsPiece || grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                        break;
                    app.flip(i, col)
                }
            }

            // Left
            var doFlip = false
            for (var i = col-1; i >= 0; i--) {
                var checkIndex = row*num_rows + i
                if (grid.children[checkIndex].containsPiece && grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                    doFlip = true
                if (!grid.children[checkIndex].containsPiece)
                    break
            }
            if (doFlip) {
                for (var i = col-1; i >= 0; i--) {
                    var checkIndex = row*num_rows + i
                    if (!grid.children[checkIndex].containsPiece || grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                        break;
                    app.flip(row, i)
                }
            }

            // Right
            var doFlip = false
            for (var i = col+1; i < num_rows; i++) {
                var checkIndex = row*num_rows + i
                if (grid.children[checkIndex].containsPiece && grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                    doFlip = true
                if (!grid.children[checkIndex].containsPiece)
                    break
            }
            if (doFlip) {
                for (var i = col+1; i < num_rows; i++) {
                    var checkIndex = row*num_rows + i
                    if (!grid.children[checkIndex].containsPiece || grid.children[checkIndex].children[1].isWhite == isWhiteTurn)
                        break;
                    app.flip(row, i)
                }
            }

            // Top Left
            var doFlip = false
            var i = row-1
            var j = col-1
            while (i >= 0 && j >= 0) {

                var child = grid.children[i*num_rows+j]
                if (child.containsPiece && child.children[1].isWhite == isWhiteTurn)
                    doFlip = true
                if (!child.containsPiece)
                    break

                i--; j--;
            }
            if (doFlip) {
                i = row-1
                j = col-1
                while (i >=0 && j >= 0 && grid.children[i*num_rows+j].containsPiece && grid.children[i*num_rows+j].children[1].isWhite != isWhiteTurn) {
                    app.flip(i, j)
                    i--; j--;
                }
            }

            // Top Right
            var doFlip = false
            var i = row-1
            var j = col+1
            while (i >= 0 && j < num_rows) {

                var child = grid.children[i*num_rows+j]
                if (child.containsPiece && child.children[1].isWhite == isWhiteTurn)
                    doFlip = true
                if (!child.containsPiece)
                    break

                i--; j++;
            }
            if (doFlip) {
                i = row-1
                j = col+1
                while (i >=0 && j < num_rows && grid.children[i*num_rows+j].containsPiece && grid.children[i*num_rows+j].children[1].isWhite != isWhiteTurn) {
                    app.flip(i, j)
                    i--; j++;
                }
            }

            // Bottom Right
            var doFlip = false
            var i = row+1
            var j = col+1
            while (i < num_rows && j < num_rows) {

                var child = grid.children[i*num_rows+j]
                if (child.containsPiece && child.children[1].isWhite == isWhiteTurn)
                    doFlip = true
                if (!child.containsPiece)
                    break

                i++; j++;
            }
            if (doFlip) {
                i = row+1
                j = col+1
                while (i < num_rows && j < num_rows && grid.children[i*num_rows+j].containsPiece && grid.children[i*num_rows+j].children[1].isWhite != isWhiteTurn) {
                    app.flip(i, j)
                    i++; j++;
                }
            }

            // Bottom Left
            var doFlip = false
            var i = row+1
            var j = col-1
            while (i < num_rows && j >= 0) {

                var child = grid.children[i*num_rows+j]
                if (child.containsPiece && child.children[1].isWhite == isWhiteTurn)
                    doFlip = true
                if (!child.containsPiece)
                    break

                i++; j--;
            }
            if (doFlip) {
                i = row+1
                j = col-1
                while (i < num_rows && j >= 0 && grid.children[i*num_rows+j].containsPiece && grid.children[i*num_rows+j].children[1].isWhite != isWhiteTurn) {
                    app.flip(i, j)
                    i++; j--;
                }
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

            count()
            if (whiteCount == 0 || blackCount == 0) {
                isGameOver = true
                popup.winText = whiteCount == 0 ? 'Black wins' : 'White wins'
                popup.open()
                app.game_over(whiteCount != 0)
            } else {
                isWhiteTurn = !isWhiteTurn
            }
        }

        function onCanPlaceSignal(row, col) {
            
            var moves = getAvailableMoves()
            app.set_can_place(contains(moves, [row, col]))
        }

        function onNewGameSignal() {
            define_new_board()
            whiteHistoryContainer.children = ''
            blackHistoryContainer.children = ''
            isGameOver = false
            isWhiteTurn = false
        }

        function onAvailableMovesSignal() {

            var moves = getAvailableMoves()
            app.set_available_moves(moves)
        }

        function onGetBoardSignal() {

            var board = [num_rows, isWhiteTurn ? 1 : -1] 

            for (var i = 0; i < num_rows; i++) {
                for(var j = 0; j < num_rows; j++) {

                    var child = grid.children[i*num_rows + j]
                    if (!child.containsPiece) {
                        board.push(0)
                    } else {
                        if (child.children[1].isWhite)
                            board.push(1)
                        else
                            board.push(-1)
                    }
                }
            }

            app.set_board(board)
        }

        function onFoldSignal() {

            isGameOver = true
            if (isBoardFull()) {
                app.game_over(!isWhiteTurn)
                if (numWhite == numBlack) {
                    popup.winText = "Draw"
                    popup.open()
                } else {
                    popup.winText = numWhite > numBlack ? 'White Wins' : 'Black Wins'
                    popup.open()
                }
            } else {
                app.game_over(!isWhiteTurn)
                popup.winText = isWhiteTurn ? 'White resigns' : 'Black resigns'
                popup.open()
            }

        }
    }
}
