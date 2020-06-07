import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageERC20
    color: Theme.darkColor6
    visible: false
    opacity: 0

    signal backClicked()


    function show() {
        visible = true
        opacity = 1

        erc20List.loadERC20List(rawUtxo)
    }

    function hide() {
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
            target: _pageERC20
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
        textTitle: "ERC-20"
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelAddressTip
        width: Theme.pw(0.9)
        height: Theme.ph(0.05)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        elide: Text.ElideRight
        text: "Ethereum " + Lang.txtAddress + " :"
    }

    QTextField {
        id: labelAddress
        width: Theme.pw(0.91)
        height: Theme.ph(0.08)
        anchors.top: labelAddressTip.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: Theme.baseSize
        textColor: Config.coinColor(coinType)
        text: address
    }

    ERC20List {
        id: erc20List
        width: Theme.pw(1)
        anchors.top: labelAddress.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onTransferClicked: {
            pageTransfer.show(tbalance, tname, tdecimal, tsymbol, tcontract, balance)
        }
    }

    ERC20Transfer {
        id: pageTransfer
        anchors.fill: parent
        onBackClicked: {
            pageTransfer.hide()
        }
    }
}
