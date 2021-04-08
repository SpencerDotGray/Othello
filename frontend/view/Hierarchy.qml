
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

Rectangle {

    ColumnLayout {

        id: container
        width: parent.width
        Layout.alignment: Qt.AlignTop
    }

    Button {

        anchors {
            horizontalCenter: parent.horizontalCenter
            bottom: parent.bottom
            bottomMargin: 10
        }

        contentItem: Text {
            text: qsTr('+')
        }

        onClicked: app.add_entry()
    }

    Component {
        id: hierItem
        Rectangle {
            property var header: ''
            height: 45

            Layout.alignment: Qt.AlignHCenter
            Rectangle { width: parent.width; height: 1; color: 'slategrey'; anchors.top: parent.top }
            Text {
                text: header
                font.bold: true
                font.pixelSize: 20
                verticalAlignment: Text.AlignVCenter 
                horizontalAlignment: Text.AlignHCenter
                anchors {
                    centerIn: parent
                }
            }
            Rectangle { width: parent.width; height: 1; color: 'slategrey'; anchors.bottom: parent.bottom }

            MouseArea {
                anchors.fill: parent
                onClicked: app.focus_entry(parent.header)
            }
        }
    }

    Connections {

        target: app

        function onAddEntrySignal(title) {

            hierItem.createObject(container, { 'header': title, 'width': container.width })
        }

        function onUpdateHeaderSignal(oldVal, newVal) {

            for (var i = 0; i < container.children.length; i++) {

                if (container.children[i].header == oldVal)
                    container.children[i].header = newVal
            }
            app.focus_entry(newVal)
        }

        function onClearHierarchySignal() {
            container.children = ''
        }
    }
}