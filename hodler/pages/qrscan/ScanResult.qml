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


Rectangle {
    id: _pageScanResult
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property int reqID: -1
    property string coinType: ""
    property string fromAddress: ""
    property string toAddress: ""
    property int utxoamount: 0
    property string amount: ""
    property string fee: ""
    property string changeback: ""
    property string rawTransaction: ""
    property string jsonTransaction: ""
    property var rawset: ({})
    property bool hasFromAddr: false

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

        hasFromAddr = Store.checkAddress(fromAddress)

        var reqset
        if (Config.isUtxoCoinType(coinType)) {
            utxoamount = item["a"]
        } else if (Config.isWeitCoinType(coinType)) {
            try {
                reqset = JSON.parse(rawTransaction)
                rawset = {}
                rawset["chainID"]     = reqset["c"]
                rawset["nonce"]       = reqset["n"]
                rawset["fromAddress"] = reqset["f"]
                rawset["toAddress"]   = reqset["t"]
                rawset["value"]       = reqset["v"]
                rawset["gasLimit"]    = reqset["gl"]
                rawset["gasPrice"]    = reqset["gp"]
                rawset["fee"]         = reqset["fe"]
                rawset["raw"]         = rawTransaction
                jsonTransaction = JSON.stringify(rawset, "", "  ")
                amount = HDMath.weiToEth(reqset["v"])
//                var gasLimit = reqset["gl"]
//                var gasPrice = reqset["gp"]
//                fee = HDMath.mul(gasLimit, gasPrice)
//                fee = HDMath.weiToEth(fee)
                fee = reqset["fe"]
            } catch (e) {
                return false
            }
        } else if (coinType == "XRP") {
            reqset = JSON.parse(rawTransaction)
            rawset = {}
            rawset["sequence"]       = reqset["n"]
            rawset["ledgerSequence"] = reqset["ln"]
            rawset["fromAddr"]       = reqset["f"]
            rawset["toAddr"]         = reqset["t"]
            rawset["value"]          = reqset["v"]
            rawset["fee"]            = reqset["fe"]
            rawset["tag"]            = reqset["tag"]
            jsonTransaction = JSON.stringify(rawset, "", "  ")
            amount = rawset["value"]
            fee    = rawset["fee"]
        } else {
            return false
        }

        switch (coinType) {
        case "BTC":
        case "LTC":
            requestDecode(rawTransaction)
            break
        case "BCH":
        case "BSV":
            var rawpre = rawTransaction.replace(/([^:]*):[^:]*/,"$1");
            requestDecode(rawpre)
            break
        }
        return true
    }

    function requestDecode(rtx) {
        iconLoading.show()
        var jsonObj = {"params": [{
                           "mainnet": Config.mainnet,
                           "fromAddr": fromAddress,
                           "toAddr": toAddress,
                           "totalInValue": utxoamount,
                           "rawtx": rtx
                        }]}
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
            var am = reply["result"]["amount"]
            var fe = reply["result"]["fee"]
            var ch = reply["result"]["change"]
            var raw = reply["result"]["raw"]
            var jraw = JSON.parse(raw)
            jraw["raw"] = rawTransaction
            jsonTransaction = JSON.stringify(jraw, "", " ")

            amount = Config.coinsAmountString(am, coinType)
            fee = Config.coinsAmountString(fe, coinType)
            changeback = Config.coinsAmountString(ch, coinType)
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
            target: _pageScanResult
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
        height: Theme.ph(0.05)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Config.coinColor(coinType)
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtCoinType + " :  " + coinType
    }

    Label {
        id: labelFrom
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelCoinType.bottom
        anchors.topMargin: Theme.ph(0.02)
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
        anchors.topMargin: -Theme.ph(0.01)
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
        anchors.topMargin: -Theme.ph(0.01)
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
            font.pointSize: Theme.middleSize
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
            font.pointSize: Theme.middleSize
            color: Theme.lightColor1
            text: coinType
        }
    }

    QLinkButton {
        id: linkShowRaw
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

    QButton {
        id: btnSignTx
        visible: hasFromAddr
        text: Lang.txtSignTx
        anchors.top: linkShowRaw.bottom
        anchors.topMargin: Theme.ph(0.07)
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            Config.requestPin(pinCallback)
        }
    }

    function pinCallback() {
        pageSignedTransaction.show()
        pageSignedTransaction.signTransaction(coinType, fromAddress, rawTransaction)
    }

    Label {
        id: labelAddrTip
        visible: !hasFromAddr
        text: Lang.tipFromAddr
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: linkShowRaw.bottom
        anchors.topMargin: Theme.ph(0.06)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor8
        font.pointSize: Theme.middleSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
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

    SignedTransaction {
        id: pageSignedTransaction
        anchors.fill: parent
        onBackClicked: {
            pageSignedTransaction.hide()
            _pageScanResult.backClicked()
        }
    }

    QLoading {
        id: iconLoading
        anchors.fill: parent
    }
}
