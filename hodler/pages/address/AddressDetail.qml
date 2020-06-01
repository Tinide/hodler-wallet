import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Key 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"
import "qrc:/pages/history"


Rectangle {
    id: _pageAddressDetail
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property string coinType: "BTC"
    property string address: ""
    property int bip39m1: 0
    property int bip39m2: 0
    property int historyCount: 0

    signal backClicked()

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        labelAddress.inputFocus = false
        opacity = 0
        actionFadeout.running = true
        pageSignMessage.hide()
        pageAddressHistory.hide()
        pageDumpPrivKey.hide()
    }

    function loadAddressData(ct, addr, m1, m2) {
        coinType = ct
        address = addr
        bip39m1 = m1
        bip39m2 = m2
        labelAddress.text = Config.coinAddrPrefix(coinType) + addr
        qrCode.qrdata = Config.coinAddrPrefix(coinType) + addr

        historyCount = Store.getSignHistoryCount(coinType, addr)
        linkHistory.text = Lang.txtTxSignedHistory + " - " + historyCount
    }

    Connections {
        target: Config
        onHideHomeBar: {
            if (_pageAddressDetail.visible) {
                _pageAddressDetail.backClicked()
            }
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
            target: _pageAddressDetail
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            labelAddress.inputFocus = false
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtAddressDetail
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    QTextField {
        id: labelAddress
        width: Theme.pw(1)
        height: Theme.ph(0.08)
        anchors.top: barTitle.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        textColor: Config.coinColor(coinType)
        textArea.font.pointSize: Theme.baseSize
        textArea.wrapMode: Text.Wrap
        textArea.horizontalAlignment: Text.AlignHCenter
        textArea.verticalAlignment: Text.AlignVCenter
    }

    QRCode {
        id: qrCode
        anchors.top: labelAddress.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.horizontalCenter: parent.horizontalCenter
    }

    QButton {
        id: btnSignMsg
        text: Lang.txtSignMsg
        anchors.top: qrCode.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.left: qrCode.left
        onClicked: {
            labelAddress.inputFocus = false
            pageSignMessage.show()
        }
        visible: coinType === "BTC" || coinType === "ETH"
    }

    QLinkButton {
        id: linkHistory
        text: Lang.txtTxSignedHistory
        height: Theme.ph(0.04)
        anchors.top: qrCode.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.right: qrCode.right
        textColor: Theme.lightColor4
        onClicked: {
            labelAddress.inputFocus = false
            if (historyCount <= 0) {
                Theme.showToast(Lang.msgNoRecord)
                return
            }
            pageAddressHistory.show()
        }
    }

    QLinkButton {
        id: linkPrivKey
        text: Lang.txtShowPrivKey
        anchors.top: linkHistory.bottom
        anchors.right: qrCode.right
        textColor: Theme.lightColor8
        onClicked: {
            labelAddress.inputFocus = false
            Config.requestPin(dumpkeyCallback)
        }
    }

    function dumpkeyCallback() {
        pageDumpPrivKey.show()
    }

    SignMessage {
        id: pageSignMessage
        anchors.fill: parent
        coinType: _pageAddressDetail.coinType
        address: _pageAddressDetail.address
        bip39m1: _pageAddressDetail.bip39m1
        bip39m2: _pageAddressDetail.bip39m2
        onBackClicked: {
            pageSignMessage.hide()
        }
    }

    AddressHistory {
        id: pageAddressHistory
        anchors.fill: parent
        coinType: _pageAddressDetail.coinType
        address: _pageAddressDetail.address
        onBackClicked: {
            pageAddressHistory.hide()
        }
    }

    DumpPrivateKey {
        id: pageDumpPrivKey
        anchors.fill: parent
        coinType: _pageAddressDetail.coinType
        address: _pageAddressDetail.address
        bip39m1: _pageAddressDetail.bip39m1
        bip39m2: _pageAddressDetail.bip39m2
        onBackClicked: {
            pageDumpPrivKey.hide()
        }
    }
}
