
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

Rectangle {

    property var entry_title: ''

    ColumnLayout {

        id: container
        anchors.fill: parent
    }

    Component {
        id: singleLineTextField 
        ColumnLayout {

            property var header: ''

            Layout.alignment: Qt.AlignHCenter

            function fillTextField(value) {
                textField.text = value
            }

            Text {
                text: qsTr(header)
                font.pixelSize: 20
            }
            TextField { 
                id: textField
                onAccepted: app.update_entry(entry_title, header, text)
            } 
        }
    }

    Component {
        id: richTextEditor
        ColumnLayout {

            property var header: ''

            Layout.alignment: Qt.AlignHCenter

            function fillTextField(value) {
                textField.text = value
            }

            Text {
                text: qsTr(header)
                font.pixelSize: 20
            }
            TextArea {
                id: textField
                onEditingFinished: app.update_entry(entry_title, header, text)
            }
        }
    }

    Connections {

        target: app

        function onAddFormEntrySignal(header, type) {

            if (type == 'Single Line Text Field') {
                singleLineTextField.createObject(container, { 'header': header })
            } else if (type == 'Rich Text Editor') {
                richTextEditor.createObject(container, { 'header': header })
            }
        }

        function onClearFormEntrySignal() {
            container.children = ''
        }

        function onFocusEntrySignal(entryHeader, values) {

            entry_title = entryHeader

            for (var i = 0; i < container.children.length; i++) {
                container.children[i].fillTextField(values[i])
            }
        }
    }
}