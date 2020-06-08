import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Key 1.0
import HD.Store 1.0
import HD.Math 1.0
import Theme 1.0
import "qrc:/common"
import "qrc:/pages/history"


Rectangle {
    id: _pageTransactionDetail
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property int reqID: -1
    property string coinType: ""
    property string createDatetime: ""
    property string fromAddress: ""
    property string toAddress: ""
    property string utxoamount: ""
    property string amount: ""
    property string fee: ""
    property string changeback: ""
    property string rawTransaction: ''
    property string jsonTransaction: "" // jsObject format

    signal backClicked()


    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
        dialogRawTransaction.hide()
    }

    function loadJsonData(jsonData) {
        var item = JSON.parse(jsonData)
        coinType = item["coinType"]
        createDatetime = item["datetime"]
        fromAddress = item["fromAddr"]
        toAddress = item["toAddr"]
        amount = "" + item["amount"]
        fee = "" + item["fee"]
        if (Config.isUtxoCoinType(coinType)) {
            utxoamount = item["utxoamount"]
        }
        rawTransaction = item["raw"]
        jsonTransaction = rawTransaction

        switch (coinType) {
        case "BTC":
        case "LTC":
        case "ETH":
        case "ERC20":
        case "ETC":
        case "XRP":
            requestDecode(rawTransaction)
            break
        case "BCH":
        case "BSV":
            var rawpre = rawTransaction.replace(/([^:]*):[^:]*/,"$1");
            requestDecode(rawpre)
            break
        }
    }

    function requestDecode(rtx) {
        var jsonObj
        if (Config.isUtxoCoinType(coinType)) {
            jsonObj = {"params": [{
                                   "mainnet": Config.mainnet,
                                   "fromAddr": fromAddress,
                                   "toAddr": toAddress,
                                   "totalInValue": parseInt(utxoamount),
                                   "rawtx": rtx
                                }]}
        } else if (Config.isWeitCoinType(coinType) || coinType === "ERC20") {
            jsonObj = {"params": [{
                                   "chainID": Config.mainnet ? "1" : "3",
                                   "rawtx": rtx
                                }]}
        } else if (coinType == "XRP") {
            jsonObj = {"params": [{
                                   "rawtx": rtx
                                }]}
        } else {
            return false
        }
        var methodPre = coinType
        if (coinType === "ERC20") {
            methodPre = "ETH"
        }
        iconLoading.show()
        reqID = JsonRpc.rpcCall(methodPre + ".DecodeRawTxOut", jsonObj, "",
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
                Theme.showToast("DecodeRawTxOut: " + reply["error"])
                return
            }
            try {
                if (Config.isUtxoCoinType(coinType)) {
                    var am = reply["result"]["amount"]
                    var fe = reply["result"]["fee"]
                    var ch = reply["result"]["change"]
                    var raw = reply["result"]["raw"]
                    var jraw = JSON.parse(raw)
                    jraw["raw"] = rawTransaction
                    jsonTransaction = JSON.stringify(jraw, "", "  ")
                    amount = Config.coinsAmountString(am, coinType)
                    fee = Config.coinsAmountString(fe, coinType)
                    changeback = Config.coinsAmountString(ch, coinType)
                } else if (Config.isWeitCoinType(coinType) || coinType === "ERC20") {
                    reply["result"]["raw"] = rawTransaction
                    jsonTransaction = JSON.stringify(reply["result"], "", " ")
                    var to = reply["result"]["recipient"]
                    var fr = reply["result"]["from"]
                    if (to !== toAddress || fr !== fromAddress) {
                        throw Lang.txtBadTransaction
                    }
//                    var va = reply["result"]["value"]
//                    var gl = reply["result"]["gaslimit"]
//                    var gp = reply["result"]["gasprice"]
//                    var gf = HDMath.mul(gl, gp)
//                    fee = HDMath.weiToEth(gf)
                    var vw = reply["result"]["value"]
                    if (coinType !== "ERC20") {
                        amount = HDMath.weiToEth(vw)
                    }
                    //txid = reply["result"]["txid"]
                } else if (coinType == "XRP") {
                    reply["result"]["raw"] = rawTransaction
                    jsonTransaction = JSON.stringify(reply["result"], "", " ")
                    amount = reply["result"]["amount"]
                    fee = reply["result"]["fee"]
                    if (   reply["result"]["toAddr"]   !== toAddress
                        || reply["result"]["fromAddr"] !== fromAddress) {
                        throw Lang.txtBadTransaction
                    }
                }
            } catch (e) {
                Theme.showToast("DecodeRawTxOut: " + e)
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
            target: _pageTransactionDetail
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtTransactionDetail
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelCoinType
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Config.coinColor(coinType)
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtCoinType + " :  " + coinType
    }

    Label {
        id: labelCreateDatetime
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelCoinType.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor6
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtCreateDateTime + " :  " + createDatetime
    }

    Label {
        id: labelFrom
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelCreateDatetime.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtFrom + " :"
    }

    Label {
        id: labelFromAddress
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelFrom.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: Config.coinColor(coinType)
        font.pointSize: Theme.middleSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: fromAddress
    }

    Label {
        id: labelTo
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelFromAddress.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtTo + " :"
    }

    Label {
        id: labelToAddress
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelTo.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: Config.coinColor(coinType)
        font.pointSize: Theme.middleSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: toAddress
    }

    Label {
        id: labelAmount
        width: Theme.pw(0.2)
        height: Theme.ph(0.06)
        anchors.top: labelToAddress.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.left: labelTo.left
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtAmount + " :"
    }

    Label {
        id: labelAmountValue
        width: paintedWidth
        height: Theme.ph(0.06)
        anchors.top: labelToAddress.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.left: labelAmount.right
        anchors.leftMargin: Theme.pw(0.02)
        color: Config.coinColor(coinType)
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: amount

        Label {
            id: labelUnit1
            width: Theme.pw(0.1)
            height: parent.height
            anchors.left: labelAmountValue.right
            anchors.leftMargin: Theme.pw(0.02)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.pointSize: Theme.mediumSize
            color: Theme.lightColor1
            text: coinType
        }
    }

    Label {
        id: labelFee
        width: Theme.pw(0.2)
        height: Theme.ph(0.06)
        anchors.top: labelAmount.bottom
        anchors.left: labelAmount.left
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtFee + " :"
    }

    Label {
        id: labelFeeValue
        width: paintedWidth
        height: Theme.ph(0.06)
        anchors.top: labelAmount.bottom
        anchors.left: labelFee.right
        anchors.leftMargin: Theme.pw(0.02)
        color: Config.coinColor(coinType)
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: fee

        Label {
            id: labelUnit2
            width: Theme.pw(0.1)
            height: parent.height
            anchors.left: labelFeeValue.right
            anchors.leftMargin: Theme.pw(0.02)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.pointSize: Theme.mediumSize
            color: Theme.lightColor1
            text: coinType
        }
    }

//    Label {
//        id: labelChangeBack
//        width: Theme.pw(0.9)
//        height: Theme.ph(0.06)
//        anchors.top: labelFeeValue.bottom
//        anchors.topMargin: Theme.ph(0.01)
//        anchors.horizontalCenter: parent.horizontalCenter
//        color: Theme.lightColor1
//        font.pointSize: Theme.middleSize
//        wrapMode: Text.Wrap
//        horizontalAlignment: Text.AlignLeft
//        verticalAlignment: Text.AlignVCenter
//        text: Lang.txtChangeBack + ":"
//    }

//    Label {
//        id: labelChangeBackValue
//        width: Theme.pw(0.9)
//        height: Theme.ph(0.06)
//        anchors.top: labelChangeBack.bottom
//        anchors.horizontalCenter: parent.horizontalCenter
//        color: Config.coinColor(coinType)
//        font.pointSize: Theme.middleSize
//        wrapMode: Text.Wrap
//        horizontalAlignment: Text.AlignLeft
//        verticalAlignment: Text.AlignVCenter
//        text: changeback
//    }

    QLinkButton {
        id: linkHistory
        text: Lang.txtShowRawTransaction
        width: textAlias.paintedWidth
        height: Theme.ph(0.04)
        anchors.top: labelFeeValue.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.right: labelCoinType.right
        //anchors.rightMargin: parent.width * 0.05
        textColor: Theme.lightColor1
        onClicked: {
            dialogRawTransaction.show()
        }
    }

    QDialog {
        id: dialogRawTransaction

        Label {
            id: labelRawTransaction
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogRawTransaction.content.width
            height: dialogRawTransaction.content.height * 0.1
            anchors.top: dialogRawTransaction.content.top
            anchors.horizontalCenter: dialogRawTransaction.content.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: Lang.txtRawTransaction
        }

        QInputField {
            id: inputRawTransaction
            readOnly: true
            scrollBarAlwaysOn: true
            selectByMouse: false
            width: dialogRawTransaction.content.width * 0.9
            height: dialogRawTransaction.content.height * 0.8
            anchors.top: dialogRawTransaction.content.top
            anchors.topMargin: dialogRawTransaction.content.height * 0.1
            anchors.left: dialogRawTransaction.content.left
            anchors.leftMargin: dialogRawTransaction.content.width * 0.05
            text: jsonTransaction
        }

        onClosed: {
            inputRawTransaction.inputFocus = false
        }
    }
}
