import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _itemMainHistory
    color: Theme.darkColor7

    property int status: -1
    property string txid: ""
    property string coinType: ""
    property string dateTime: ""
    property string fromAddr: ""
    property string toAddr: ""
    property string amount: ""
    property string fee: ""
    property string rawTx: ""
    property string outline: ""
    property string jsonData: ""
    property string utxoamount: ""

    signal clicked()
    signal deleted()


    onStatusChanged: {
        labelStatus.text = Config.txStatusString(coinType, status)
    }

    Component.onCompleted: {
        if (status == -1) {
            agent.sendTransaction(coinType, txid, rawTx)
        }
        timerTxid.start()
    }

    function requestTxid() {
        if (agent.utxoIsConfirmed(coinType, status)) {
            return
        }
        var txreq = txid
        if (agent.isUtxoCoinType(coinType)) {
            txreq += ":" + toAddr
        }
        agent.searchTransaction(coinType, txreq)
    }

    Timer {
        id: timerTxid
        interval: Config.pingInterval + ((Math.floor(Math.random()*(60))+10)*1000)
        repeat: true
        onTriggered: {
            if (agent.utxoIsConfirmed(coinType, status)) {
                timerTxid.stop()
                return
            }
            if (status == -1) {
                agent.sendTransaction(coinType, txid, rawTx)
            }
            requestTxid()
        }
    }

    Connections {
        target: Config
        onTransactionResult: {
            if (td !== txid) {
                return
            }
            if (status == -2) {
                return
            }
            try {
                var jobj = JSON.parse(result)
                var confirms = jobj["confirmations"]
                if (status == -3 && confirms === -1) {
                    return
                }
                if (confirms > status || confirms < -1) {
                    ss = confirms
                    Store.updateTxRecord(txid, status)
                }
            } catch (e) {}
        }
    }

    Item {
        id: itemLeft
        width: parent.width
        height: parent.height

        Image {
            id: iconCoin
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.01
            height: parent.height * 0.8
            width: height
            anchors.verticalCenter: parent.verticalCenter
            source: Config.coinIconSource(coinType)
        }

        Rectangle {
            id: lineSpace1
            width: Theme.mm(0.21)
            height: parent.height * 0.8
            anchors.left: iconCoin.right
            anchors.leftMargin: parent.width * 0.01
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.darkColor8
        }

        Label {
            id: labelStatus
            anchors.left: lineSpace1.right
            width: parent.width * 0.23
            height: parent.height
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Theme.baseSize
            color: status < 0 ? Theme.lightColor8 : Theme.lightColor1
            wrapMode: Text.Wrap
            text: Config.txStatusString(coinType, status)
        }

        Rectangle {
            id: lineSpace2
            width: Theme.mm(0.21)
            height: parent.height * 0.8
            anchors.left: labelStatus.right
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.darkColor8
        }

        Label {
            id: labelOutline
            anchors.left: lineSpace2.right
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
            height: Theme.mm(0.21)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            color: Theme.darkColor8
        }

        SequentialAnimation {
            id: animationPress
            ColorAnimation {
                target: _itemMainHistory
                property: "color"
                from: Theme.darkColor7
                to: Theme.darkColor8
                duration: 150
            }
            ColorAnimation {
                target: _itemMainHistory
                property: "color"
                from: Theme.darkColor8
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
            _itemMainHistory.deleted()
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
        onClicked: {
            var txreq = txid
            if (agent.isUtxoCoinType(coinType)) {
                txreq += ":" + toAddr
            }
            if (status <= 0 || agent.utxoIsConfirmed(coinType, status) === false) {
                agent.searchTransaction(coinType, txreq)
            }
            _itemMainHistory.clicked()
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
