import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _itemAddress
    color: Theme.darkColor7

    property alias address: labelAddr.text
    property string label: ""
    property string tokenType: ""

    signal clicked()

    Item {
        id: itemLeft
        width: parent.width
        height: parent.height

        Label {
            id: labelLabel
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.01
            width: parent.width * 0.25
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Theme.baseSize
            color: Config.coinColor(tokenType)
            elide: Text.ElideRight
            text: label
        }

        Rectangle {
            id: lineSpace2
            width: Theme.mm(0.21)
            height: parent.height * 0.8
            anchors.left: labelLabel.right
            anchors.leftMargin: parent.width * 0.03
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.darkColor8
        }

        Label {
            id: labelAddr
            anchors.left: lineSpace2.right
            anchors.leftMargin: parent.width * 0.03
            anchors.right: parent.right
            anchors.rightMargin: parent.width * 0.03
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.pointSize: Theme.baseSize
            color: Config.coinColor(tokenType)
            elide: Text.ElideMiddle
            //wrapMode: Text.Wrap

            Behavior on scale {
                PropertyAnimation{
                    easing.type: Easing.InOutQuad
                    duration: 100
                }
            }
        }

        Rectangle {
            id: lineBottom
            width: parent.width
            height: Theme.mm(0.21)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            color: Theme.darkColor8
        }

        SequentialAnimation {
            id: animationPress
            ColorAnimation {
                target: _itemAddress
                property: "color"
                from: Theme.darkColor7
                to: Theme.darkColor3
                duration: 150
            }
            ColorAnimation {
                target: _itemAddress
                property: "color"
                from: Theme.darkColor3
                to: Theme.darkColor7
                duration: 140
            }
        }
    }


    MouseArea {
        anchors.fill: itemLeft
        hoverEnabled: true
        onClicked: {
            _itemAddress.clicked()
        }
        onPressed: {
            animationPress.start()
        }
    }
}
