import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageAddAddress
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property int reqID: -1
    property string coinType: "BTC"

    signal backClicked()
    signal addClicked(string address, string label, string ct)

    function show() {
        visible = true
        opacity = 1
        inputAddress.text = ""
        inputLabel.text = ""
    }

    function hide() {
        inputAddress.inputFocus = false
        inputLabel.inputFocus = false
        opacity = 0
        actionFadeout.running = true
    }

    function requestValidate(addr) {
        iconLoading.show()
        var jsonObj = {"params": [{
                           "address": addr,
                           "mainnet": Config.mainnet
                        }]}
        reqID = JsonRpc.rpcCall(coinType + ".AddressValidate", jsonObj, "",
                                Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
    }

    Connections {
        target: JsonRpc
        onRpcReply: {
            if (id != reqID) {
                return
            }
            iconLoading.hide()

            if (reply["error"] !== null) {
                Theme.showToast("AddressValidate: " + reply["error"])
                return
            }

            var addr = inputAddress.text
            if (agent.isWeitCoinType(coinType)) {
                addr = addr.toLowerCase()
            }
            Store.addAddress(addr, inputLabel.text, coinType)
            addClicked(addr, inputLabel.text, coinType)
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
            target: _pageAddAddress
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            inputAddress.inputFocus = false
            inputLabel.inputFocus = false
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtAddAddress
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelInput
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: barTitle.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        elide: Text.ElideRight
        text: Lang.txtInput + " " + Config.coinName(coinType) + " " + Lang.txtAddress + " :"

        QLinkButton {
            id: linkTokenType
            text: Lang.txtCoinType
            width: textAlias.paintedWidth
            height: parent.height
            anchors.right: labelInput.right
            textColor: Theme.lightColor1
            onClicked: {
                dialogToken.show()
            }
        }
    }

    QInputField {
        id: inputAddress
        width: Theme.pw(0.9)
        height: Theme.ph(0.145)
        anchors.top: labelInput.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        textColor: Config.coinColor(coinType)
    }

    Label {
        id: labelLabel
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: inputAddress.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        elide: Text.ElideRight
        text: Lang.txtLabel + " :"
    }

    QInputField {
        id: inputLabel
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelLabel.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        textColor: Theme.lightColor1
        area.placeholderText: Lang.txtNoLabel
    }

    QButton {
        id: btnAdd
        anchors.top: inputLabel.bottom
        anchors.topMargin: Theme.ph(0.055)
        anchors.horizontalCenter: parent.horizontalCenter
        text: Lang.txtAdd
        onClicked: {
            if (Store.checkAddress(inputAddress.text)) {
                Theme.showToast(Lang.msgExistsAddress)
                return
            }
            requestValidate(inputAddress.text)
        }
    }

    DialogToken {
        id: dialogToken
        onTokenClicked: {
            coinType = strCoin
            dialogToken.hide()
        }
    }
}
