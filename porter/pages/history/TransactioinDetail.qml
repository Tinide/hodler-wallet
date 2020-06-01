import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
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
    property int status: -1
    property string txid: ""
    property string coinType: ""
    property string createDatetime: ""
    property string fromAddress: ""
    property string toAddress: ""
    property string amount: ""
    property string fee: ""
    property string utxoamount: ""
    property string changeback: ""
    property string rawTransaction: ""
    property string jsonTransaction: "" // jsObject format
    // bch, bsv
    property string inputamounts: ""

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

    function loadJsonData(ss, jsonData) {
        var item = JSON.parse(jsonData)
        txid = item["txid"]
        coinType = item["coinType"]
        createDatetime = item["datetime"]
        fromAddress = item["fromAddr"]
        toAddress = item["toAddr"]
        if (agent.isUtxoCoinType(coinType)) {
            amount = "" + Config.normalFloatString(item["amount"])
            fee = "" + Config.normalFloatString(item["fee"])
            utxoamount = "" + item["utxoamount"]
        } else {
            amount = "" + item["amount"]
            fee = "" + item["fee"]
        }
        rawTransaction = item["raw"]
        jsonTransaction = rawTransaction
        status = ss

        var rc = false
        switch (coinType) {
        case "BTC":
        case "LTC":
        case "ETH":
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
        } else if (coinType == "XRP") {
            jsonObj = {"params": [{
                                   "rawtx": rtx
                                }]}
        } else {
            return false
        }
        reqID = JsonRpc.rpcCall(coinType + ".DecodeRawTxOut", jsonObj, "",
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
                if (agent.isUtxoCoinType(coinType)) {
                    var am = reply["result"]["amount"]
                    var fe = reply["result"]["fee"]
                    var ch = reply["result"]["change"]
                    var raw = reply["result"]["raw"]
                    var jraw = JSON.parse(raw)
                    if (jraw["txid"] !== txid) {
                        Config.debugOut("txid compare failed.")
                    }
                    jraw["raw"] = rawTransaction
                    jsonTransaction = JSON.stringify(jraw, "", "  ")
                    if (coinType == "BCH" || coinType == "BSV") {
                        inputamounts = rawTransaction.replace(/[^:]*:([^:]*)/,"$1")
                    }
                    amount = Config.coinsAmountString(am, coinType)
                    fee = Config.coinsAmountString(fe, coinType)
                    changeback = ch
                } else if (agent.isWeitCoinType(coinType)) {
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
                    amount = HDMath.weiToEth(vw)
                    txid = reply["result"]["txid"]
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

    Connections {
        target: Config
        onTransactionResult: {
            if (td !== txid) {
                return
            }
            if (status == -2) {
                return
            }
            try {
                var jobj = JSON.parse(result)
                var ss = jobj["confirmations"]
                if (status == -3 && ss === -1) {
                    return
                }
                if (ss > status || ss < -1) {
                    status = ss
                }
            } catch (e) {}
        }
    }

    onStatusChanged: {
        labelStatus.text = Lang.txtStatus + " : " + Config.txStatusString(coinType, status)
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
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Config.coinColor(coinType)
        font.pointSize: Theme.middleSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtCoinType + " :  " + coinType

        Label {
            id: labelStatus
            width: Theme.pw(0.5)
            height: Theme.ph(0.06)
            anchors.top: labelCoinType.top
            anchors.right: parent.right
            color: status < 0 ? Theme.lightColor8 : Theme.lightColor1
            font.pointSize: Theme.middleSize
            horizontalAlignment: Text.AlignRight
            verticalAlignment: Text.AlignVCenter
            text: Lang.txtStatus + " : " + Config.txStatusString(coinType, status)
        }
    }

    Label {
        id: labelCreateDatetime
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelCoinType.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor6
        font.pointSize: Theme.middleSize
        wrapMode: Text.Wrap
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
        wrapMode: Text.Wrap
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
        wrapMode: Text.Wrap
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
        anchors.topMargin: Theme.ph(0.02)
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
        text: Lang.txtRaw
        width: textAlias.paintedWidth
        height: Theme.ph(0.04)
        anchors.top: labelFeeValue.bottom
        //anchors.topMargin: Theme.ph(0.01)
        anchors.right: labelCoinType.right
        textColor: Theme.lightColor1
        onClicked: {
            dialogRawTransaction.show()
        }
    }

    QLinkButton {
        id: linkMarkDelete
        text: Lang.txtMarkDeleted
        width: textAlias.paintedWidth
        height: Theme.ph(0.04)
        anchors.top: linkHistory.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.left: labelAmount.left
        textColor: Theme.lightColor1
        visible: status == -1 || status == 0
        onClicked: {
            dialogMarkConfirm.show()
        }
    }

    QLinkButton {
        id: linkReplace
        text: Lang.txtReplaceByFee
        width: textAlias.paintedWidth
        height: Theme.ph(0.04)
        anchors.top: linkHistory.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.right: labelCoinType.right
        textColor: Theme.lightColor1
        visible: coinType == "XRP" ? false : (status == 0 || status == -1 || status == -2)
        onClicked: {
            dialogReplaceConfirm.show()
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

    QDialog {
        id: dialogMarkConfirm
        content.height: Theme.ph(0.33)
        content.anchors.topMargin: Theme.ph(0.3)

        Label {
            id: txtMarkTip
            text: Lang.txtMarkDeleteTip
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogMarkConfirm.content.width * 0.8
            height: dialogMarkConfirm.content.height * 0.5
            anchors.horizontalCenter: dialogMarkConfirm.content.horizontalCenter
            anchors.top: dialogMarkConfirm.content.top
            anchors.bottom: btnConfirm.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        QButton {
            id: btnConfirm
            text: Lang.txtConfirm
            anchors.left: dialogMarkConfirm.content.left
            anchors.leftMargin: Theme.pw(0.03)
            anchors.bottom: dialogMarkConfirm.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                status = -3
                var result = {"confirmations":-3}
                Config.transactionResult(txid, JSON.stringify(result))
                dialogMarkConfirm.hide()
            }
        }

        QButton {
            id: btnCancel
            text: Lang.txtCancel
            anchors.right: dialogMarkConfirm.content.right
            anchors.rightMargin: Theme.pw(0.03)
            anchors.bottom: dialogMarkConfirm.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                dialogMarkConfirm.hide()
            }
        }
    }

    QDialog {
        id: dialogReplaceConfirm
        content.height: Theme.ph(0.33)
        content.anchors.topMargin: Theme.ph(0.3)

        Label {
            id: txtReplaceTip
            text: Lang.txtReplaceByFeeTip
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogReplaceConfirm.content.width * 0.8
            height: dialogReplaceConfirm.content.height * 0.5
            anchors.horizontalCenter: dialogReplaceConfirm.content.horizontalCenter
            anchors.top: dialogReplaceConfirm.content.top
            anchors.bottom: btnReplaceConfirm.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        QButton {
            id: btnReplaceConfirm
            text: Lang.txtConfirm
            anchors.left: dialogReplaceConfirm.content.left
            anchors.leftMargin: Theme.pw(0.03)
            anchors.bottom: dialogReplaceConfirm.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                pageReplace.show()
                dialogReplaceConfirm.hide()
            }
        }

        QButton {
            id: btnReplaceCancel
            text: Lang.txtCancel
            anchors.right: dialogReplaceConfirm.content.right
            anchors.rightMargin: Theme.pw(0.03)
            anchors.bottom: dialogReplaceConfirm.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                dialogReplaceConfirm.hide()
            }
        }
    }

    ReplaceByFee {
        id: pageReplace
        anchors.fill: parent
        onBackClicked: {
            pageReplace.hide()
        }
    }
}
