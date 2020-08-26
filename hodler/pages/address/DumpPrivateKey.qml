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
    id: _pageDumpPrivKey
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property string coinType: "BTC"
    property alias address: labelAddress.text
    property int bip39m1: 0
    property int bip39m2: 0
    property int reqID: -1

    signal backClicked()

    function show() {
        visible = true
        opacity = 1
        requestKey()
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
    }

    function requestKey() {
        iconLoading.show()
        var entropy = Key.getEntropy()
        var jsonObj = {"params": [{
                           "entropy": entropy,
                           "seed": Config.seed,
                           "m1": bip39m1,
                           "m2": bip39m2,
                           "compresspubkey": Config.compressPubkey,
                           "mainnet": Config.mainnet
                        }]}
        reqID = JsonRpc.rpcCall(coinType + ".DumpPrivateKey", jsonObj, "",
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
                Theme.showToast("SignMessage: " + reply["error"])
                return
            }
            if (coinType == "EOS") {
                labelKey1.text = "Owner Key WIF format:"
                labelKey2.text = "Active Key WIF format:"
                textKey1.text = reply["result"]["wif1"]
                textKey2.text = reply["result"]["wif2"]
            } else if (coinType == "XRP") {
                labelKey1.text = "Serect format:"
                labelKey2.text = "HEX format:"
                textKey1.text = reply["result"]["secret"]
                textKey2.text = reply["result"]["hex"]
            } else if (coinType == "FIL") {
                labelKey1.text = "Keyinfo format:"
                labelKey2.text = "HEX format:"
                textKey1.text = reply["result"]["secret"]
                textKey2.text = reply["result"]["hex"]
            } else {
                labelKey1.text = "WIF format:"
                labelKey2.text = "HEX format:"
                textKey1.text = reply["result"]["wif"]
                textKey2.text = reply["result"]["hex"]
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
            target: _pageDumpPrivKey
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            textKey1.inputFocus = false
            textKey2.inputFocus = false
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtPrivKey
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            textKey1.inputFocus = false
            textKey2.inputFocus = false
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

    Label {
        id: labelKey1
        width: Theme.pw(0.9)
        height: paintedHeight
        anchors.top: labelAddress.bottom
        anchors.topMargin: Theme.ph(0.05)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor8
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: "WIF format:"
    }

    QTextField {
        id: textKey1
        width: Theme.pw(0.9)
        height: Theme.pw(0.25)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: labelKey1.bottom
        anchors.topMargin: parent.height * 0.022
        selectByMouse: true
    }

    Label {
        id: labelKey2
        width: Theme.pw(0.9)
        height: paintedHeight
        anchors.top: textKey1.bottom
        anchors.topMargin: Theme.ph(0.04)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor8
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: "HEX format:"
    }

    QTextField {
        id: textKey2
        width: Theme.pw(0.9)
        height: Theme.pw(0.2)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: labelKey2.bottom
        anchors.topMargin: parent.height * 0.022
        selectByMouse: true
    }
}
