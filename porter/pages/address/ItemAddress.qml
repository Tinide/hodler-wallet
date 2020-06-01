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
    clip: true

    property string address: ""
    property string label: ""
    property string tokenType: ""

    property string balance: "-"
    property string pending: "-"
    property string total: "-"
    property string dat: ""

    signal clicked()
    signal deleted()


    Component.onCompleted: {
        timerSync.start()
    }

    Connections {
        target: Config
        onBalanceResult: {
            if (addr != address) {
                return
            }
            _itemAddress.balance = balance
            _itemAddress.pending = pending
            _itemAddress.total = total
            _itemAddress.dat = dat
        }
    }

    Timer {
        id: timerSync
        repeat: true
        interval: Config.pingInterval + ((Math.floor(Math.random()*(300))+60)*1000)
        onTriggered: {
            agent.syncBalance(tokenType, address)
        }
    }

    Item {
        id: itemLeft
        width: parent.width
        height: parent.height

        Image {
            id: imgToken
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.01
            height: parent.height * 0.8
            width: height
            anchors.verticalCenter: parent.verticalCenter
            source: Config.coinIconSource(tokenType)
        }

        Rectangle {
            id: lineSpace1
            width: Theme.mm(0.21)
            height: parent.height * 0.8
            anchors.left: imgToken.right
            anchors.leftMargin: parent.width * 0.01
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.darkColor8
        }

        Label {
            id: labelLabel
            anchors.left: lineSpace1.right
            anchors.leftMargin: parent.width * 0.03
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
            text: address

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

        Behavior on x {
            PropertyAnimation{
                easing.type: Easing.OutQuart
                duration: 200
            }
        }
    }

    QButton {
        id: btnDelete
        radius: 0
        height: parent.height
        anchors.left: itemLeft.right
        anchors.right: parent.right
        color: "#E54747"
        clip: true
        text: Lang.txtDelete
        onClicked: {
            _itemAddress.deleted()
        }

        Rectangle {
            id: lineBottom2
            width: parent.width
            height: Theme.mm(0.21)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            color: Theme.darkColor8
        }
    }

    MouseArea {
        property real oldX: 0
        anchors.fill: itemLeft
        hoverEnabled: true
        onClicked: {
            _itemAddress.clicked()
        }
        onPressed: {
            animationPress.start()
            oldX = itemLeft.x
        }
        onReleased: {
            if (itemLeft.x >= oldX) {
                itemLeft.x = 0
            } else {
                itemLeft.x = -parent.width * 0.2
            }
        }
        drag.target: itemLeft
        drag.axis: Drag.XAxis
        drag.minimumX: -parent.width * 0.2
        drag.maximumX: 0
    }
}
