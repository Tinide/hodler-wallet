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
    id: _pageTransaction
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property int reqID: -1
    property int reqIDAddr1: -1
    property int reqIDAddr2: -1
    property string rawtx: ""
    property int curPage: 0
    property int maxPage: 0
    property int capPage: Store.getQRCapacity() - 150
    property string utxoamount: "0"

    signal backClicked()


    onRawtxChanged: {
        capPage = Store.getQRCapacity() - 150
        var txl = rawtx.length
        maxPage = (txl / capPage) + 1
        curPage = 1
    }

    onCurPageChanged: {
        if (curPage <= 0) {
            return
        }
        showQRPageCode()
    }

    function show() {
        visible = true
        opacity = 1

        utxoamount = _pageTransactionDetail.utxoamount
        if (checkAddress() === false) {
            hide()
            return
        }

        status = -3
        var result = {"confirmations":-3}
        Config.transactionResult(txid, JSON.stringify(result))
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
        rawtx = ""
        qrCode.qrdata = ""
        maxPage = 0
        curPage = 0
    }

    function checkAddress() {
        if (agent.isUtxoCoinType(coinType)) {
            var bala = parseFloat(utxoamount) + 0.000000001
            var val  = parseFloat(labelAmountValue.text)
            var fee  = parseFloat(labelFeeValue.text)
            if (val + fee > bala) {
                Theme.showToast(Lang.msgBalanceNotEnough)
                return false
            }
        } else if (agent.isWeitCoinType(coinType)) {
//            var va = HDMath.ethToWei(labelAmountValue.text)
//            var vf = HDMath.ethToWei(labelFeeValue.text)
//            var vb = HDMath.ethToWei(amount)
//            var tot = HDMath.add(va, vf)
//            if (HDMath.cmp(tot, vb) > 0) {
//                Theme.showToast(Lang.msgBalanceNotEnough)
//                return false
//            }
        }
        if (coinType === "BTC") {
            if (fee > 0.01) {
                Theme.showToast("fee > 0.01")
                return false
            }
            if (Config.mainnet && fee <= 0.00001) {
                Theme.showToast("fee < 0.00001")
                return false
            }
        }

        var jsonObj = {"params": [{
                           "address": fromAddress,
                           "mainnet": Config.mainnet
                        }]}
        reqIDAddr1 = JsonRpc.rpcCall(coinType + ".AddressValidate", jsonObj, "",
                                     Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
        jsonObj = {"params": [{
                           "address": toAddress,
                           "mainnet": Config.mainnet
                        }]}
        reqIDAddr2 = JsonRpc.rpcCall(coinType + ".AddressValidate", jsonObj, "",
                                     Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)

        return true
    }

    function showQRPageCode() {
        var qrd = {}
        qrd["s"] = "HODL"
        qrd["m"] = "TX"
        qrd["c"] = curPage
        qrd["p"] = maxPage
        qrd["t"] = coinType
        qrd["f"] = fromAddress
        qrd["o"] = toAddress
        if (agent.isUtxoCoinType(coinType)) {
            qrd["a"] = utxoamount
        } else {
            qrd["a"] = labelAmountValue.text
            qrd["e"] = labelFeeValue.text
        }
        if (curPage == maxPage) {
            qrd["d"] = rawtx.substr((curPage - 1) * capPage)
        } else {
            qrd["d"] = rawtx.substr(((curPage - 1) * capPage), capPage)
        }
        var jsonstr = JSON.stringify(qrd)
        qrCode.qrdata = jsonstr

        //console.info(JSON.stringify(jsonstr, "", "  "))
    }

    function handleAddressValidate(id,reply) {
        if (reply["error"] !== null) {
            Theme.showToast(Lang.msgAddressInvalidate + ": " + reply["error"])
            hide()
        }
        if (id !== reqIDAddr2) {
            return
        }
        var jsonObj
        if (agent.isUtxoCoinType(coinType)) {
            var am = Config.coinsAmountValue(labelAmountValue.text, coinType)
            var fe = Config.coinsAmountValue(labelFeeValue.text, coinType)
            var uam = parseInt(utxoamount)
            jsonObj = agent.createReplacedTransactionRequest(coinType,fromAddress,toAddress,
                                                                 am,fe,uam,txins)
            //console.info(JSON.stringify(jsonObj, "", "  "))
            if (jsonObj === []) {
                Theme.showToast(Lang.msgCreateTxFailed)
                hide()
            }
            reqID = JsonRpc.rpcCall(coinType + ".CreateRawTx", {"params": jsonObj}, "",
                                    Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
        } else if (agent.isWeitCoinType(coinType)) {
            var dset = {}
            dset["n"] = nonce
            dset = JSON.stringify(dset)
            jsonObj = agent.createTransactionRequest(coinType,fromAddress,toAddress,
                                                     labelAmountValue.text,labelFeeValue.text,dset)
            if (jsonObj === null) {
                Theme.showToast(Lang.msgCreateTxFailed)
                hide()
            }
            if (Config.debugMode) {
                rawtx = JSON.stringify(jsonObj, "", "  ")
                //console.info(rawtx)
            } else {
                rawtx = JSON.stringify(jsonObj)
            }
            showQRPageCode()
        } else {
            Theme.showToast(coinType + " create tx not implement")
        }
    }

    Connections {
        target: JsonRpc
        onRpcReply: {
            switch (id) {
            case reqIDAddr1:
            case reqIDAddr2:
                handleAddressValidate(id,reply)
                return
            case reqID:
                break
            default:
                return
            }
            if (reply["error"] !== null) {
                Theme.showToast("CreateRawTx: " + reply["error"])
                return
            }
            if (coinType == "BCH" || coinType == "BSV") {
                rawtx = reply["result"]["rawtx"] + ":" + inputamounts
                //console.info(rawtx)
            } else {
                rawtx = reply["result"]["rawtx"]
            }
            showQRPageCode()
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
            target: _pageTransaction
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtRawTransaction
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    QRCode {
        id: qrCode
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Label {
        id: labelScanWith
        width: paintedWidth
        height: Theme.ph(0.05)
        anchors.left: qrCode.left
        anchors.leftMargin: Theme.pw(0.05)
        anchors.verticalCenter: imgHodler.verticalCenter
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: "Scan with "
    }

    Image {
        id: imgHodler
        width: Theme.pw(0.08)
        height: width
        anchors.top: qrCode.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.left: labelScanWith.right
        anchors.leftMargin: Theme.pw(0.03)
        source: "qrc:/images/AddressIcon.png"
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }

    Label {
        id: labelToSign
        width: paintedWidth
        height: Theme.ph(0.05)
        anchors.left: imgHodler.right
        anchors.leftMargin: Theme.pw(0.03)
        anchors.verticalCenter: imgHodler.verticalCenter
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: "to sign."
    }

    Label {
        id: labelPages
        width: Theme.pw(0.5)
        height: Theme.ph(0.05)
        anchors.left: labelToSign.right
        anchors.leftMargin: Theme.pw(0.04)
        anchors.verticalCenter: imgHodler.verticalCenter
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtPage + "  " + curPage + " / " + maxPage
    }

    QLinkButton {
        id: linkRaw
        text: Lang.txtRaw
        width: textAlias.paintedWidth
        height: Theme.ph(0.05)
        anchors.top: labelPages.top
        anchors.right: qrCode.right
        textColor: Theme.lightColor1
        onClicked: {
            dialogRaw.show()
        }
    }

    QButton {
        id: btnPrevPage
        visible: maxPage > 1
        text: "<"
        textAlias.font.pointSize: Theme.mediumSize
        anchors.top: labelPages.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.right: qrCode.right
        anchors.rightMargin: qrCode.width * 0.52
        onClicked: {
            if (curPage > 1) {
                curPage--
            }
        }
    }

    QButton {
        id: btnNextPage
        visible: maxPage > 1
        text: ">"
        textAlias.font.pointSize: Theme.mediumSize
        anchors.top: labelPages.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.left: qrCode.left
        anchors.leftMargin: qrCode.width * 0.52
        onClicked: {
            if (curPage < maxPage) {
                curPage++
            }
        }
    }

    QDialog {
        id: dialogRaw
        QTextField {
            id: textRaw
            scrollBarAlwaysOn: true
            selectByMouse: true
            width: dialogRaw.content.width * 0.9
            height: dialogRaw.content.height * 0.9
            anchors.top: dialogRaw.content.top
            anchors.topMargin: dialogRaw.content.height * 0.05
            anchors.left: dialogRaw.content.left
            anchors.leftMargin: dialogRaw.content.width * 0.05
            text: rawtx
        }
        onClosed: {
            textRaw.inputFocus = false
        }
    }
}
