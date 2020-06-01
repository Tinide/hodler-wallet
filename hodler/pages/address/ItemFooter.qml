import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


Item {
    id: _itemFooter

    signal leftClicked()
    signal rightClicked()

    Rectangle {
        id: rectBackground
        width: parent.width
        height: Theme.ph(0.06)
        color: Theme.darkColor7

        Image {
            id: labelIndex
            anchors.left: parent.left
            width: parent.width * 0.5
            height: parent.height * 0.25
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/BtnArrow.png"
            mipmap: true
            transformOrigin: Item.Center
            rotation: 180
        }

        Rectangle {
            id: lineSpace
            width: Theme.mm(0.2)
            height: parent.height * 0.8
            anchors.left: labelIndex.right
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.darkColor8
        }

        Image {
            id: labelAddr
            anchors.left: lineSpace.right
            anchors.right: parent.right
            height: parent.height * 0.25
            anchors.verticalCenter: parent.verticalCenter
            fillMode: Image.PreserveAspectFit
            source: "qrc:/images/BtnArrow.png"
            mipmap: true
        }

        Rectangle {
            id: lineBottom
            width: parent.width
            height: Theme.mm(0.2)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            color: Theme.darkColor8
        }

        MouseArea {
            hoverEnabled: true
            anchors.left: parent.left
            width: parent.width * 0.5
            height: parent.height
            onClicked: {
                leftClicked()
            }
        }

        MouseArea {
            hoverEnabled: true
            anchors.left: lineSpace.right
            anchors.right: parent.right
            height: parent.height
            onClicked: {
                rightClicked()
            }
        }
    }
}
