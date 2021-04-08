
import QtQuick 2.0
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.15
import QtQuick.Window 2.12
import QtQuick.Controls.Material 2.12

ApplicationWindow {

    id: window  
    width: 1200
    height: 600
    visible: true

    MouseArea {
        anchors.fill: parent
        onClicked: forceActiveFocus()
    }

    Rectangle {

        anchors.fill: parent

        Navbar {

            id: navBar

            width: parent.width * (1/6)
            height: parent.height

            anchors {
                left: parent.left
            }

            color: '#f4f0ec'
        }

        Rectangle {
            id: divOne
            width: 1
            height: parent.height
            color: 'slategrey'

            anchors {
                left: navBar.right
            }
        }

        FormCreator {

            id: formCreator

            width: parent.width * (2/3)
            height: parent.height

            anchors {
                left: divOne.right
            }

            color: '#fefefa'
        }

        Rectangle {
            id: divTwo
            width: 1
            height: parent.height
            color: 'slategrey'
            z: 2

            anchors {
                left: formCreator.right
            }
        }

        Hierarchy {

            id: hierarchy

            width: parent.width * (1/6)
            height: parent.height

            anchors {
                left: divTwo.left
            }

            color: '#f4f0ec'
        }
    }
}
