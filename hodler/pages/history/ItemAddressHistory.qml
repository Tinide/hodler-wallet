import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _itemHistory
    color: Theme.darkColor7

    property string coinType: ""
    property string dateTime: ""
    property string fromAddr: ""
    property string toAddr: ""
    property string amount: ""
    property string fee: ""
    property string rawTx: ""
    property string outline: ""
    property string jsonData: ""

    signal clicked()


    Label {
        id: labelDatetime
        anchors.left: parent.left
        width: parent.width * 0.2
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: Theme.baseSize
        color: Config.coinColor(coinType)
        text: dateTime
        wrapMode: Text.Wrap
    }

    Rectangle {
        id: lineSpace
        width: Theme.mm(0.2)
        height: parent.height * 0.8
        anchors.left: labelDatetime.right
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.darkColor8
    }

    Label {
        id: labelOutline
        anchors.left: lineSpace.right
        anchors.leftMargin: parent.width * 0.02
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.02
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Config.coinColor(coinType)
        elide: Text.ElideMiddle
        Behavior on scale {
            PropertyAnimation{
                easing.type: Easing.InOutQuad
                duration: 100
            }
        }
        text: outline
    }

    Rectangle {
        id: lineBottom
        width: parent.width
        height: Theme.mm(0.2)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        color: Theme.darkColor8
    }

    SequentialAnimation {
        id: animationPress
        ColorAnimation {
            target: _itemHistory
            property: "color"
            from: Theme.darkColor7
            to: Theme.darkColor8
            duration: 150
        }
        ColorAnimation {
            target: _itemHistory
            property: "color"
            from: Theme.darkColor8
            to: Theme.darkColor7
            duration: 140
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            _itemHistory.clicked()
        }
        onPressed: {
            animationPress.start()
        }
    }
}
