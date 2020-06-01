import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageVerify
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property int reqID: -1
    property string coinType: "BTC"
    property string defaultAddr: "1HoDLmanwkpmQ9VNuoBKbAL3thiJy8YoFb"
    property string defaultMsg: "hello hodler"
    property string defaultSig: "ILSv6huDanikYMyGZNyg4sXPIW/7OsDO7cD3L0ySsK3UEogLN8i0ciWyBtd7W8QWWcooGidRtYZ+GO3MTlqfrkc="

    signal backClicked()

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        dialogCoins.hide()
        opacity = 0
        actionFadeout.running = true
        inputAddress.inputFocus = false
        inputMessage.inputFocus = false
        inputSignature.inputFocus = false
    }

    function requestVerify() {
        iconLoading.show()
        var jsonObj = {"params": [{
                           "address": inputAddress.text,
                           "message": inputMessage.text,
                           "signature": inputSignature.text,
                           "mainnet": Config.mainnet
                        }]}
        reqID = JsonRpc.rpcCall(coinType + ".VerifyMessage", jsonObj, "",
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
                Theme.showToast("VerifyMessage: " + reply["error"])
                return
            }
            Theme.showToast(reply["result"]["result"])
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
            target: _pageVerify
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            inputAddress.inputFocus = false
            inputMessage.inputFocus = false
            inputSignature.inputFocus = false
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtVerifySignature
        textLeft: Lang.txtBack
        textRight: Lang.txtCoinType + "  > "
        onRightClicked: {
            dialogCoins.show()
        }
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
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: coinType + " " + Lang.txtAddress

        Image {
            id: iconScan
            width: height
            height: parent.height
            anchors.right: labelAddress.right
            anchors.rightMargin: width * 0.5
            source: Store.Theme > 1 ? "qrc:/images/QRScanIconDark.png" : "qrc:/images/QRScanIcon.png"
            mipmap: true
            fillMode: Image.PreserveAspectFit
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    pageScan.callBackScan(addrScanCallback)
                }
            }
        }
    }

    function addrScanCallback(result) {
        if (result.indexOf(":") !== -1) {
            result = result.replace(/[^:]*:([^:]*)/,"$1")
        }
        inputAddress.text = result
    }

    QInputField {
        id: inputAddress
        width: Theme.pw(0.9)
        height: Theme.pw(0.15)
        textColor: Config.coinColor(coinType)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: labelAddress.bottom
        anchors.topMargin: parent.height * 0.012
        selectByMouse: true
        readOnly: false
        text: defaultAddr
    }

    Label {
        id: labelMessage
        width: Theme.pw(0.9)
        height: paintedHeight
        anchors.top: inputAddress.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor6
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtEnterMessage
    }

    QInputField {
        id: inputMessage
        width: Theme.pw(0.9)
        height: Theme.pw(0.2)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: labelMessage.bottom
        anchors.topMargin: parent.height * 0.022
        selectByMouse: true
        text: defaultMsg
    }

    Label {
        id: labelSignature
        width: Theme.pw(0.7)
        height: paintedHeight
        anchors.top: inputMessage.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor6
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtEnterSignature
        wrapMode: Text.Wrap

        Image {
            id: iconScan2
            width: height
            height: labelAddress.height
            anchors.right: labelSignature.right
            anchors.rightMargin: (width * 0.5) - Theme.pw(0.1)
            anchors.verticalCenter: parent.verticalCenter
            source: Store.Theme > 1 ? "qrc:/images/QRScanIconDark.png" : "qrc:/images/QRScanIcon.png"
            mipmap: true
            fillMode: Image.PreserveAspectFit
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    pageScan.callBackScan(sigScanCallback)
                }
            }
        }
    }

    function sigScanCallback(result) {
        if (result.indexOf(":") !== -1) {
            result = result.replace(/[^:]*:([^:]*)/,"$1")
        }
        inputSignature.text = result
    }

    QInputField {
        id: inputSignature
        width: Theme.pw(0.9)
        height: Theme.pw(0.3)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: labelSignature.bottom
        anchors.topMargin: parent.height * 0.022
        selectByMouse: true
        text: defaultSig
    }

    QButton {
        id: btnVerify
        text: Lang.txtVerify
        anchors.top: inputSignature.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.right: inputSignature.right
        onClicked: {
            if (   inputAddress.text == ""
                || inputMessage.text == ""
                || inputSignature.text == "") {
                Theme.showToast(Lang.msgInputEmpty)
                return
            }
            requestVerify()
        }
    }

    DialogSignMsgCoinType {
        id: dialogCoins
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onCoinClicked: {
            if (strCoin != coinType) {
                coinType = strCoin
                if (coinType == "ETH") {
                    inputAddress.text = "0x61ef9781aa572f73321f7afbf7c5c8897e4fa9fb"
                    inputMessage.text = "hello hodler"
                    inputSignature.text = "0x124611641c230fdf4a3dcfbc2a42d6711264fd994ccefd60319bb3f204adce7b13c01f6e001e6cc8aeaeb6259c773e431cc5e769fbf817334b252b9d5fc91b8b01"
                } else if (coinType == "BTC") {
                    inputAddress.text = "1HoDLmanwkpmQ9VNuoBKbAL3thiJy8YoFb"
                    inputMessage.text = "hello hodler"
                    inputSignature.text = "ILSv6huDanikYMyGZNyg4sXPIW/7OsDO7cD3L0ySsK3UEogLN8i0ciWyBtd7W8QWWcooGidRtYZ+GO3MTlqfrkc="
                }
            }
            hide()
        }
    }

    QLoading {
        id: iconLoading
        anchors.fill: parent
    }
}
