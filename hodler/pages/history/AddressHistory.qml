import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Key 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageAddressHistory
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property string coinType: "BTC"
    property alias address: labelAddress.text

    signal backClicked()

    function show() {
        visible = true
        opacity = 1
        listAddressHistory.loadAddressHistory(coinType, address)
    }

    function hide() {
        transactionDetail.hide()
        opacity = 0
        actionFadeout.running = true
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
            target: _pageAddressHistory
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtHistory
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelAddress
        width: Theme.pw(0.9)
        height: paintedHeight
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Config.coinColor(coinType)
        font.pointSize: Theme.baseSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    ListAddressHistory {
        id: listAddressHistory
        coinType: _pageAddressHistory.coinType
        address: _pageAddressHistory.address
        anchors.top: labelAddress.bottom
        anchors.topMargin: Theme.ph(0.022)
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        onItemClicked: {
            transactionDetail.loadJsonData(jsonData)
            transactionDetail.show()
        }
    }

    TransactioinDetail {
        id: transactionDetail
        anchors.fill: parent
        onBackClicked: {
            transactionDetail.hide()
        }
    }
}
