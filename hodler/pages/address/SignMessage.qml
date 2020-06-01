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
    id: _pageSignMessage
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
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
        inputMessage.text = ""
        signResult.hide()
    }

    function requestSign() {
        iconLoading.show()
        var entropy = Key.getEntropy()
        var jsonObj = {"params": [{
                           "entropy": entropy,
                           "seed": Config.seed,
                           "m1": bip39m1,
                           "m2": bip39m2,
                           "compresspubkey": Config.compressPubkey,
                           "mainnet": Config.mainnet,
                           "message": inputMessage.text
                        }]}
        reqID = JsonRpc.rpcCall(coinType + ".SignMessage", jsonObj, "",
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
            var sig = reply["result"]["signature"]
            signResult.signature = sig
            signResult.show()
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
            target: _pageSignMessage
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            inputMessage.inputFocus = false
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtSignMsg
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

    Label {
        id: labelTip
        width: Theme.pw(0.9)
        height: paintedHeight
        anchors.top: labelAddress.bottom
        anchors.topMargin: parent.height * 0.05
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor6
        font.pointSize: Theme.middleSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtInputMsgTip
    }

    QInputField {
        id: inputMessage
        selectByMouse: false
        scrollBarAlwaysOn: true
        width: Theme.pw(0.9)
        height: Theme.pw(0.6)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: labelTip.bottom
        anchors.topMargin: parent.height * 0.03
    }

    QButton {
        id: btnSign
        text: Lang.txtSign
        anchors.top: inputMessage.bottom
        anchors.topMargin: parent.height * 0.04
        anchors.right: inputMessage.right
        onClicked: {
            if (inputMessage.text == "") {
                Theme.showToast(Lang.txtInputMsgTip)
                return
            }
            inputMessage.inputFocus = false
            requestSign()
        }
    }

    SignMessageResult {
        id: signResult
        anchors.fill: parent
        coinType: _pageSignMessage.coinType
        address: _pageSignMessage.address
        onBackClicked: {
            signResult.hide()
        }
    }
}
