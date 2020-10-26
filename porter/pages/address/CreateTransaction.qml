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
    id: _pageCreateTransaction
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property string balance: "-"
    property string pending: "-"
    property string total: "-"
    property string rawUtxo: "[]"
    property int utxoCount: 0
    property double utxoTotal: 0

    signal backClicked()

    function show() {
        visible = true
        opacity = 1

        var bestFee = agent.getBestFee(coinType)
        if (agent.isUtxoCoinType(coinType)) {
            utxoTotal = agent.calcUtxoTotalAmount(rawUtxo)
            var fee = parseFloat(bestFee)
            fee = agent.calcUtxoFee(1, fee) / Config.satmul
            fee = fee.toFixed(8)
            inputFee.text = "" + fee
        } else {
            inputFee.text = "" + bestFee
        }
        labelBestFee.text = Lang.txtEvalFee + inputFee.text
    }

    function hide() {
        clearFocus()
        opacity = 0
        actionFadeout.running = true
        inputAddress.text = ""
        inputAmount.text = ""
        inputFee.text = ""
        inputTag.text = ""
    }

    function clearFocus() {
        inputAddress.inputFocus = false
        inputAmount.inputFocus = false
        inputFee.inputFocus = false
    }

    function scanCallback(result) {
        if (result.indexOf(":") !== -1) {
            result = result.replace(/[^:]*:([^:]*)/,"$1")
        }
        inputAddress.text = result
    }

    function checkInput() {
        if (inputAddress.text === "") {
            Theme.showToast(Lang.txtInputToAddrTip)
            return false
        }
        if (inputAddress.text == address) {
            Theme.showToast(Lang.msgSelfSend)
            return false
        }
        if (inputAmount.text === "") {
            Theme.showToast(Lang.txtInputAmount)
            return false
        }
        if (inputFee.text === "") {
            Theme.showToast(Lang.txtInputFee)
            return false
        }
        if (agent.isWeitCoinType(coinType)) {
            address = address.toLowerCase()
            inputAddress.text = inputAddress.text.toLowerCase()
        }
        if (coinType == "XRP") {
            var ba = parseFloat(balance)
            var am = parseFloat(inputAmount.text)
            var fe = parseFloat(inputFee.text)
            if (ba - am - fe < 20.0000001) {
                Theme.showToast(Lang.msgXrpReserved)
                return false
            }
        }
        if (coinType == "DOT") {
            var nBala = HDMath.mul(balance, "10000000000")
            var nVal  = HDMath.mul(inputAmount.text, "10000000000")
            var nFee  = HDMath.mul(inputFee.text, "10000000000")
            nBala = HDMath.sub(nBala, "10000000000")
            var nTran = HDMath.add(nVal, nFee)
            nTran = HDMath.add(nTran, "0.05") // gas reserved
            if (HDMath.cmp(nTran, nBala) > 0) {
                Theme.showToast(Lang.msgBalanceNotEnough + ", " + Lang.txtReserved + " 1.05 Dot.")
                //return false
            }
        }

        return true
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
            target: _pageCreateTransaction
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            clearFocus()
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtCreateTransaction
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelFrom
        width: Theme.pw(0.9)
        height: Theme.ph(0.05)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.mediumSize
        color: Theme.lightColor1
        elide: Text.ElideRight
        text: Lang.txtFrom + " :"

        Label {
            id: labelBalance
            width: Theme.pw(0.9)
            height: parent.height
            anchors.top: labelFrom.top
            anchors.right: labelFrom.right
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            font.pointSize: Theme.baseSize
            color: Theme.lightColor1
            elide: Text.ElideRight
            text: Lang.txtBalance + " :   " + balance + " " + coinType
        }
    }

    Label {
        id: labelFromAddress
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelFrom.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignTop
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: Theme.middleSize
        color: Config.coinColor(coinType)
        text: address
        wrapMode: Text.WrapAnywhere
    }

    Label {
        id: labelTo
        width: Theme.pw(0.9)
        height: Theme.ph(0.05)
        anchors.top: labelFromAddress.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.mediumSize
        color: Theme.lightColor1
        elide: Text.ElideRight
        text: Lang.txtInputToAddrTip

        Image {
            id: iconScan
            width: height
            height: parent.height * 0.8
            anchors.right: linkAddrs.left
            anchors.rightMargin: width
            source: Store.Theme > 1 ? "qrc:/images/QRScanIconDark.png" : "qrc:/images/QRScanIcon.png"
            mipmap: true
            fillMode: Image.PreserveAspectFit
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    pageScan.callBackScan(scanCallback)
                }
            }
        }

        QLinkButton {
            id: linkAddrs
            text: Lang.txtChooseAddr
            width: textAlias.paintedWidth
            height: parent.height
            anchors.right: parent.right
            textColor: Theme.lightColor1
            onClicked: {
                clearFocus()
                listChoose.loadAddress()
                dialogChoose.show()
            }
        }
    }

    QInputField {
        id: inputAddress
        width: Theme.pw(0.9)
        height: Theme.ph(0.10)
        anchors.top: labelTo.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: Theme.baseSize
        textColor: Theme.lightColor1
    }

    Item {
        id: xrpTag
        width: Theme.pw(0.9)
        height: coinType == "XRP" ? Theme.ph(0.07) : 0
        anchors.top: inputAddress.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        clip: true

        Label {
            id: labelTag
            width: Theme.pw(0.3)
            height: Theme.ph(0.06)
            anchors.left: xrpTag.left
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.pointSize: Theme.mediumSize
            color: Theme.lightColor1
            text: Lang.txtDestinationTag
        }

        QInput {
            id: inputTag
            width: Theme.pw(0.58)
            height: Theme.ph(0.06)
            anchors.left: labelTag.right
            anchors.leftMargin: Theme.pw(0.02)
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.lightColor1
            echoPasswd: false
            validator: RegExpValidator{regExp: /[0-9]+/}
            placeText: Lang.txtTagTip
            selectByMouse: true
        }
    }

    Label {
        id: labelAmount
        width: Theme.pw(0.2)
        height: Theme.ph(0.06)
        anchors.top: xrpTag.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.left: xrpTag.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.mediumSize
        color: Theme.lightColor1
        text: Lang.txtAmount + " :"
    }

    QInput {
        id: inputAmount
        width: Theme.pw(0.58)
        height: Theme.ph(0.06)
        anchors.top: xrpTag.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.left: labelAmount.right
        anchors.leftMargin: Theme.pw(0.02)
        color: Theme.lightColor1
        echoPasswd: false
        validator: DoubleValidator{
            decimals: agent.isUtxoCoinType(coinType) ? 8 : 18
            notation: DoubleValidator.StandardNotation
        }
        //validator: RegExpValidator{regExp: /[0-9.]+/}
        placeText: Lang.txtInputAmount
        selectByMouse: true
        onInputEdited: {
            var total, val, bestFee, fee
            if (agent.isUtxoCoinType(coinType)) {
                total = Config.coinsAmountValue(balance, coinType)
                val = Config.coinsAmountValue(inputAmount.text, coinType)
                bestFee = agent.getBestFee(coinType)
                bestFee = agent.calcUtxoTotalFee(val, bestFee, rawUtxo)
                labelBestFee.text = Lang.txtEvalFee + Config.coinsAmountString(bestFee, coinType)
                fee = Config.coinsAmountValue(inputFee.text, coinType)
                if (val + fee > total) {
                    val = Config.coinsAmountString((total - fee), coinType)
                    if (val > "0.0") {
                        inputAmount.text = "" + val
                    }
                }
            } else if (agent.isWeitCoinType(coinType)) {
                val = HDMath.ethToWei(inputAmount.text)
                fee = HDMath.ethToWei(inputFee.text)
                var ba = HDMath.ethToWei(balance)
                total = HDMath.add(val, fee)
                if (HDMath.cmp(total, ba) > 0) {
                    val = HDMath.sub(ba, fee)
                    val = HDMath.weiToEth(val)
                    if (val > "0.0") {
                        inputAmount.text = "" + val
                    }
                }
            }
        }

        Label {
            id: labelUnit1
            width: Theme.pw(0.1)
            height: parent.height
            anchors.left: inputAmount.right
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
        anchors.topMargin: Theme.ph(0.02)
        anchors.left: labelAmount.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.mediumSize
        color: Theme.lightColor1
        text: Lang.txtFee + " :"
    }

    QInput {
        id: inputFee
        width: Theme.pw(0.58)
        height: Theme.ph(0.06)
        anchors.top: labelAmount.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.left: labelFee.right
        anchors.leftMargin: Theme.pw(0.02)
        color: Theme.lightColor1
        echoPasswd: false
        validator: DoubleValidator{
            decimals: agent.isUtxoCoinType(coinType) ? 8 : 9
            notation: DoubleValidator.StandardNotation
        }
        //validator: RegExpValidator{regExp: /[0-9.]+/}
        placeText: Lang.txtInputFee
        selectByMouse: true

        Label {
            id: labelUnit2
            width: Theme.pw(0.1)
            height: parent.height
            anchors.left: inputFee.right
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.pointSize: Theme.mediumSize
            color: Theme.lightColor1
            text: coinType
        }
    }

    Label {
        id: labelBestFee
        width: paintedWidth
        height: Theme.ph(0.04)
        anchors.top: inputFee.bottom
        anchors.right: inputFee.right
        anchors.rightMargin: -Theme.pw(0.05)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.smallSize
        color: Theme.lightColor2
    }

    QButton {
        id: btnCreate
        anchors.top: labelBestFee.bottom
        anchors.topMargin: Theme.ph(0.04)
        anchors.horizontalCenter: parent.horizontalCenter
        text: Lang.txtCreate
        onClicked: {
            clearFocus()
            if (checkInput() === false) {
                return
            }
            pageTransaction.show()
        }
    }

    QDialog {
        id: dialogChoose

        Label {
            id: txtChoose
            text: Lang.txtChooseRecvAddr
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogChoose.content.width * 0.8
            height: dialogChoose.content.height * 0.15
            anchors.horizontalCenter: dialogChoose.content.horizontalCenter
            anchors.top: dialogChoose.content.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        ListChoose {
            id: listChoose
            width: dialogChoose.content.width * 0.95
            height: dialogChoose.content.height * 0.77
            anchors.top: txtChoose.bottom
            anchors.horizontalCenter: dialogChoose.content.horizontalCenter
            onItemClicked: {
                inputAddress.text = addr
                dialogChoose.hide()
            }
        }
    }

    Transaction {
        id: pageTransaction
        anchors.fill: parent
        onBackClicked: {
            _pageCreateTransaction.backClicked()
            pageTransaction.hide()
        }
    }
}
