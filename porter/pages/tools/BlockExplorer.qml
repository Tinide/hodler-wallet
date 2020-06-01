import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageAddService
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property string coinType: "BTC"
    property int serviceID: 0
    property string latestTime: "-"
    property string latestBlock: "-"
    property string bestFee: "-"

    signal backClicked()
    signal addClicked()

    function show() {
        loadBlockInfo()
        visible = true
        opacity = 1
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
        latestTime = "-"
        latestBlock = "-"
        bestFee = "-"
    }

    function loadBlockInfo() {
        var serv = agent.servList[serviceID]
        if (serv.status.startsWith(Lang.txtOK)) {
            latestTime = serv.blockTime
            latestBlock = "" + serv.blockHeight
            bestFee = agent.getBestFee(coinType)
            if (agent.isUtxoCoinType(coinType)) {
                bestFee += " sat / byte"
            }
        } else {
            latestTime = "-"
            latestBlock = "-"
            bestFee = "-"
        }
    }

    Behavior on opacity {
        PropertyAnimation{
            easing.type: Easing.InOutQuad
            duration: 150
        }
    }

    SequentialAnimation {
        id: actionFadeout
        running: false

        PauseAnimation { duration: 150 }
        PropertyAction {
            target: _pageAddService
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Config.coinName(coinType) + " " + Lang.txtExplorer
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelLatestTime
        width: Theme.pw(0.4)
        height: Theme.ph(0.06)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.right: parent.right
        anchors.rightMargin: Theme.pw(0.60)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pointSize: Theme.middleSize
        color: Theme.lightColor1
        text: Lang.txtLatestTime + " :"
    }

    Label {
        id: txtLatestTime
        width: Theme.pw(0.4)
        height: Theme.ph(0.06)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.left: parent.left
        anchors.leftMargin: Theme.pw(0.44)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.middleSize
        color: Theme.lightColor1
        text: latestTime
    }

    Label {
        id: labelLatestBlock
        width: Theme.pw(0.4)
        height: Theme.ph(0.06)
        anchors.top: txtLatestTime.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.right: parent.right
        anchors.rightMargin: Theme.pw(0.60)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pointSize: Theme.middleSize
        color: Theme.lightColor1
        text: Lang.txtLatestBlock + " :"
    }

    Label {
        id: txtLatestBlock
        width: Theme.pw(0.4)
        height: Theme.ph(0.06)
        anchors.top: txtLatestTime.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.left: parent.left
        anchors.leftMargin: Theme.pw(0.44)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.middleSize
        color: Theme.lightColor1
        text: latestBlock
    }

    Label {
        id: labelBestFee
        width: Theme.pw(0.4)
        height: Theme.ph(0.06)
        anchors.top: txtLatestBlock.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.right: parent.right
        anchors.rightMargin: Theme.pw(0.60)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pointSize: Theme.middleSize
        color: Theme.lightColor1
        text: Lang.txtBestFee + " :"
    }

    Label {
        id: txtBestFee
        width: Theme.pw(0.4)
        height: Theme.ph(0.06)
        anchors.top: txtLatestBlock.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.left: parent.left
        anchors.leftMargin: Theme.pw(0.44)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.middleSize
        color: Theme.lightColor1
        text: bestFee
    }

    QButton {
        id: btnRefresh
        anchors.top: txtBestFee.bottom
        anchors.topMargin: Theme.ph(0.06)
        anchors.horizontalCenter: parent.horizontalCenter
        text: Lang.txtRefresh
        onClicked: {
            loadBlockInfo()
        }
    }
}
