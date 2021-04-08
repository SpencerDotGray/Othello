
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

Rectangle {

    ColumnLayout {

        id: linkContainer
        width: parent.width
        Layout.alignment: Qt.AlignTop
    }

    Component {
        id: navItem
        Rectangle {
            property var linkText: ''

            width: parent.width
            height: 45

            Layout.alignment: Qt.AlignHCenter
            Rectangle { width: parent.width; height: 1; color: 'slategrey'; anchors.top: parent.top }
            Text {
                id: linkT
                text: linkText
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

                onClicked: app.navigate(linkText)
            }
        }
    }

    Connections {

        target: app

        function onAddLinkSignal(linkName) {
            navItem.createObject(linkContainer, { 'linkText': linkName })
        }
    }
}