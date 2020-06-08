import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Math 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageTransactionResult
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property int reqID: -1
    property string coinType: ""
    property string fromAddress: ""
    property string toAddress: ""
    property string utxoamount: ""
    property string fee: ""
    property string rawTransaction: ""
    property string jsonTransaction: ""
    property string txid: ""
    property string spendtxs: ""

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
        coinType = item["t"]
        fromAddress = item["f"]
        toAddress = item["o"]
        rawTransaction = item["d"]
        jsonTransaction = rawTransaction

        labelTransaction.text = Config.coinName(coinType) + " " + Lang.txtSignedTransaction
        labelUnit1.text = coinType

        if (agent.isUtxoCoinType(coinType)) {
            utxoamount = "" + item["a"]
        } else if (agent.isWeitCoinType(coinType)) {
            amount = "" + item["a"]
            fee = item["fe"]
        } else if (coinType === "ERC20") {
            amount = "" + item["a"]
            fee = item["fe"]
            labelTransaction.text = "ERC-20 " + item["tn"]
            labelUnit1.text = item["sm"]
        } else if (coinType == "XRP") {
            amount = "" + item["a"]
            fee = item["fe"]
        } else {
            return false
        }

        var rc = false
        switch (coinType) {
        case "BTC":
        case "LTC":
        case "ETH":
        case "ERC20":
        case "ETC":
        case "XRP":
            rc = requestDecode(rawTransaction)
            break
        case "BCH":
        case "BSV":
            var rawpre = rawTransaction.replace(/([^:]*):[^:]*/, "$1")
            rc = requestDecode(rawpre)
            break
        }
        return rc
    }

    function requestDecode(rtx) {
        iconLoading.show()
        var jsonObj
        if (agent.isUtxoCoinType(coinType)) {
            jsonObj = {"params": [{
                                   "mainnet": Config.mainnet,
                                   "fromAddr": fromAddress,
                                   "toAddr": toAddress,
                                   "totalInValue": parseInt(utxoamount),
                                   "rawtx": rtx
                                }]}
        } else if (agent.isWeitCoinType(coinType)) {
            jsonObj = {"params": [{
                                   "chainID": Config.mainnet ? "1" : "3",
                                   "rawtx": rtx
                                }]}
        } else if (coinType === "ERC20") {
            jsonObj = {"params": [{
                                   "chainID": Config.mainnet ? "1" : "3",
                                   "rawtx": rtx
                                }]}
        } else if (coinType == "XRP") {
            jsonObj = {"params": [{
                                   "rawtx": rtx
                                }]}
        } else {
            iconLoading.hide()
            return false
        }

        var methodPre = coinType
        if (coinType === "ERC20") {
            methodPre = "ETH"
        }
        reqID = JsonRpc.rpcCall(methodPre + ".DecodeRawTxOut", jsonObj, "",
                                Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
        return true
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
                if (agent.isUtxoCoinType(coinType)) {
                    var am = reply["result"]["amount"]
                    var fe = reply["result"]["fee"]
                    var ch = reply["result"]["change"]
                    var raw = reply["result"]["raw"]
                    var jraw = JSON.parse(raw)
                    jraw["raw"] = rawTransaction
                    jsonTransaction = JSON.stringify(jraw, "", " ")
                    txid = reply["result"]["txid"]
                    spendtxs = reply["result"]["spendtx"]
                    amount = Config.coinsAmountString(am, coinType)
                    fee = Config.coinsAmountString(fe, coinType)
                } else if (agent.isWeitCoinType(coinType) || coinType === "ERC20") {
                    reply["result"]["raw"] = rawTransaction
                    jsonTransaction = JSON.stringify(reply["result"], "", " ")
                    var va = reply["result"]["value"]
//                    var gl = reply["result"]["gaslimit"]
//                    var gp = reply["result"]["gasprice"]
//                    var gf = HDMath.mul(gl, gp)
//                    fee = HDMath.weiToEth(gf)
                    var nonce = reply["result"]["nonce"]
                    spendtxs = "" + nonce
                    if (coinType !== "ERC20") {
                        amount = HDMath.weiToEth(va)
                    }
                    txid = reply["result"]["txid"]
                    var to = reply["result"]["recipient"]
                    var fr = reply["result"]["from"]
                    if (to !== toAddress || fr !== fromAddress) {
                        throw Lang.txtBadTransaction
                    }
                } else if (coinType == "XRP") {
                    reply["result"]["raw"] = rawTransaction
                    jsonTransaction = JSON.stringify(reply["result"], "", " ")
                    amount = reply["result"]["amount"]
                    fee = reply["result"]["fee"]
                    txid = reply["result"]["txid"]
                    if (   reply["result"]["toAddr"]   !== toAddress
                        || reply["result"]["fromAddr"] !== fromAddress) {
                        throw Lang.txtBadTransaction
                    }
                    //console.info(jsonTransaction)
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
            target: _pageTransactionResult
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtScanResult
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelTransaction
        width: Theme.pw(0.9)
        height: Theme.ph(0.05)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Label {
        id: labelFrom
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelTransaction.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtFrom + " :"
    }

    Label {
        id: labelFromAddress
        width: Theme.pw(0.9)
        height: Theme.ph(0.07)
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
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtTo + " :"
    }

    Label {
        id: labelToAddress
        width: Theme.pw(0.9)
        height: Theme.ph(0.07)
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
        anchors.topMargin: Theme.ph(0.02)
        anchors.left: labelTo.left
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtAmount + " :"
    }

    Label {
        id: labelAmountValue
        width: paintedWidth
        height: Theme.ph(0.06)
        anchors.top: labelToAddress.bottom
        anchors.topMargin: Theme.ph(0.02)
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
        wrapMode: Text.Wrap
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
            text: coinType == "ERC20" ? "ETH" : coinType
        }
    }

    QLinkButton {
        id: linkShowRaw
        text: Lang.txtRaw
        width: textAlias.paintedWidth
        height: Theme.ph(0.04)
        anchors.top: labelFeeValue.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.right: labelTransaction.right
        textColor: Theme.lightColor1
        onClicked: {
            dialogRawTransaction.show()
        }
    }

    QButton {
        id: btnSend
        width: Theme.buttonWidth * 1.3
        anchors.top: linkShowRaw.bottom
        anchors.topMargin: Theme.ph(0.06)
        anchors.horizontalCenter: parent.horizontalCenter
        text: Lang.txtSendTransaction
        onClicked: {
            agent.sendTransaction(coinType, txid, rawTransaction)
            Store.appendTxRecord(txid, coinType, fromAddr, toAddr, amount, fee, rawTransaction,
                                 utxoamount, spendtxs)
//            var result = {"confirmations":-1}
//            Config.transactionResult(txid, JSON.stringify(result))
            _pageTransactionResult.backClicked()
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
            selectByMouse: true
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

    QLoading {
        id: iconLoading
        anchors.fill: parent
    }
}
