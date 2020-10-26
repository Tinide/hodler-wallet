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
    id: _pageTransactionDetail
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property int reqID: -1
    property string signedTx: ""
    property int curPage: 0
    property int maxPage: 0
    property int capPage: Store.getQRCapacity() - 150

    signal backClicked()


    onSignedTxChanged: {
        capPage = Store.getQRCapacity() - 150
        var txl = signedTx.length
        maxPage = (txl / capPage) + 1
        curPage = 1
    }

    onCurPageChanged: {
        if (curPage <= 0) {
            return
        }

        showQRPageCode()
    }

    function showQRPageCode() {
        var qrd = {}
        qrd["s"] = "HODL"
        qrd["m"] = "TXS"
        qrd["c"] = curPage
        qrd["p"] = maxPage
        qrd["t"] = coinType
        qrd["f"] = fromAddr
        qrd["o"] = toAddr
        switch (coinType) {
        case "BTC":
        case "BCH":
        case "BSV":
        case "LTC":
            qrd["a"]  = utxoamount
            break
        case "ERC20":
            qrd["a"]  = amount
            qrd["fe"] = fee
            qrd["co"] = rawset["contract"]
            qrd["sm"] = rawset["symbol"]
            qrd["tn"] = rawset["tokenName"]
            qrd["td"] = rawset["decimal"]
            break
        default:
            qrd["a"]  = amount
            qrd["fe"] = fee
        }
        if (curPage == maxPage) {
            qrd["d"] = signedTx.substr((curPage - 1) * capPage)
        } else {
            qrd["d"] = signedTx.substr(((curPage - 1) * capPage), capPage)
        }
        var jsonstr = JSON.stringify(qrd)
        qrCode.qrdata = jsonstr
        //console.info(jsonstr)
    }

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
        signedTx = ""
        qrCode.qrdata = ""
        maxPage = 0
        curPage = 0
    }

    function signTransaction(cointype, fromaddr, rawtx) {
        iconLoading.show()
        var jsonObj
        if (Config.isUtxoCoinType(cointype)) {
            jsonObj = {"params": [{
                                   "entropy": Key.getEntropy(),
                                   "seed": Config.seed,
                                   "m1": Config.coinsM1(cointype),
                                   "m2": Store.getAddressM2(fromaddr),
                                   "compresspubkey": Config.compressPubkey,
                                   "mainnet": Config.mainnet,
                                   "rawtx": rawtx
                                 }]}
        } else if (Config.isWeitCoinType(cointype)) {
            jsonObj = {"params": [{
                                   "entropy": Key.getEntropy(),
                                   "seed": Config.seed,
                                   "m1": Config.coinsM1(cointype),
                                   "m2": Store.getAddressM2(fromaddr),
                                   "nonce": rawset["nonce"],
                                   "gasLimit": rawset["gasLimit"],
                                   "gasPrice": rawset["gasPrice"],
                                   "value": rawset["value"],
                                   "chainID": rawset["chainID"],
                                   "toAddress": rawset["toAddress"]
                                 }]}
        } else if (cointype === "ERC20") {
            jsonObj = {"params": [{
                                   "entropy": Key.getEntropy(),
                                   "seed": Config.seed,
                                   "m1": Config.coinsM1(cointype),
                                   "m2": Store.getAddressM2(fromaddr),
                                   "nonce": rawset["nonce"],
                                   "gasLimit": rawset["gasLimit"],
                                   "gasPrice": rawset["gasPrice"],
                                   "value": rawset["value"],
                                   "chainID": rawset["chainID"],
                                   "contract": rawset["contract"],
                                   "toAddress": rawset["toAddress"]
                                 }]}
        } else if (coinType == "XRP") {
            jsonObj = {"params": [{
                                   "entropy": Key.getEntropy(),
                                   "seed": Config.seed,
                                   "m1": Config.coinsM1(cointype),
                                   "m2": Store.getAddressM2(fromaddr),
                                   "sequence": rawset["sequence"],
                                   "ledgerSequence": rawset["ledgerSequence"],
                                   "currency": "XRP",
                                   "value": rawset["value"],
                                   "fee": rawset["fee"],
                                   "toAddr": rawset["toAddr"],
                                   "tag": rawset["tag"]
                                 }]}
        } else if (coinType == "DOT") {
            var dval = HDMath.mul(rawset["value"], "10000000000")
            var dfee = HDMath.mul(rawset["fee"],   "10000000000")
            jsonObj = {"params": [{
                                   "entropy": Key.getEntropy(),
                                   "seed": Config.seed,
                                   "m1": Config.coinsM1(cointype),
                                   "m2": Store.getAddressM2(fromaddr),
                                   "nonce": "" + rawset["nonce"],
                                   "toAddress": rawset["toAddress"],
                                   "amount": dval,
                                   "fee": dfee
                                 }]}
        }

        if (coinType === "ERC20") {
            reqID = JsonRpc.rpcCall("ETH.SignRawTxERC20", jsonObj, "",
                                    Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
        } else {
            reqID = JsonRpc.rpcCall(cointype + ".SignRawTx", jsonObj, "",
                                    Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
        }
    }

    Connections {
        target: JsonRpc
        onRpcReply: {
            if (id != reqID) {
                return
            }
            iconLoading.hide()
            if (reply["error"] !== null) {
                Theme.showToast("SignRawTx: " + reply["error"])
                return
            }
            signedTx = reply["result"]["result"]
            if (coinType === "ERC20") {
                utxoamount = JSON.stringify(rawset, "", " ")
            }
            Store.appendSignHistory(coinType, "", fromAddr, toAddr, "" + utxoamount, "" + amount, fee, signedTx)
            Config.historyChanged()
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
        textTitle: Lang.txtSignedTx
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

    Image {
        id: imgPorter
        width: Theme.pw(0.12)
        height: width
        anchors.top: qrCode.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.left: qrCode.left
        anchors.leftMargin: qrCode.width * 0.31
        source: "qrc:/images/PorterIcon.png"
        fillMode: Image.PreserveAspectFit
        mipmap: true
    }

    Label {
        id: labelCoinType
        width: Theme.pw(0.5)
        height: Theme.ph(0.05)
        anchors.left: imgPorter.right
        anchors.leftMargin: Theme.pw(0.02)
        anchors.verticalCenter: imgPorter.verticalCenter
        color: Config.coinColor(coinType)
        font.pointSize: Theme.mediumSize
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtPage + "  " + curPage + " / " + maxPage
    }

    QButton {
        id: btnPrevPage
        visible: maxPage > 1
        text: "<"
        textAlias.font.pointSize: Theme.mediumSize
        anchors.top: labelCoinType.bottom
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
        anchors.top: labelCoinType.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.left: qrCode.left
        anchors.leftMargin: qrCode.width * 0.52
        onClicked: {
            if (curPage < maxPage) {
                curPage++
            }
        }
    }
}
