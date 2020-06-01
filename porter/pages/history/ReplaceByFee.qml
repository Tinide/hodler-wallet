import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"
import "qrc:/pages/history"


Rectangle {
    id: _pageReplace
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property string txins: ""
    property string nonce: "0"

    signal backClicked()

    function show() {
        visible = true
        opacity = 1

        labelAmountValue.text = amount
        labelFeeValue.text = fee

        if (agent.isUtxoCoinType(coinType)) {
            parseUtxoset()
        } else if (agent.isWeitCoinType(coinType)) {
            try {
                var dataset = JSON.parse(jsonTransaction)
                nonce = "" + dataset["nonce"]
            } catch(e) {
                Theme.showToast(e)
                hide()
                return
            }
        }
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
        dialogRawTransaction.hide()
        labelFeeValue.inputFocus = false
    }

    function parseUtxoset() {
        try {
            var inputs = []
            var txset = JSON.parse(jsonTransaction)
            for (var i = 0; i < txset["TxIn"].length; i++) {
                var u = {}
                u["txid"]     = txset["TxIn"][i]["txid"]
                u["vout"]     = txset["TxIn"][i]["vout"]
                u["sequence"] = txset["TxIn"][i]["sequence"]
                inputs.push(u)
            }
            txins = JSON.stringify(inputs, "", "  ")
        } catch (e) {
            Theme.showToast(e)
            hide()
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
            target: _pageReplace
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            labelFeeValue.inputFocus = false
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtReplaceTransaction
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelFrom
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
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
        font.pointSize: Theme.mediumSize
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
        anchors.topMargin: Theme.ph(0.03)
        anchors.left: labelToAddress.left
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtAmount + " :"
    }

    QInput {
        id: labelAmountValue
        width: Theme.pw(0.58)
        height: Theme.ph(0.06)
        anchors.top: labelToAddress.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.left: labelAmount.right
        anchors.leftMargin: Theme.pw(0.02)
        color: Theme.lightColor1
        echoPasswd: false
        validator: DoubleValidator{
            decimals: agent.isUtxoCoinType(coinType) ? 8 : 18
            notation: DoubleValidator.StandardNotation
        }
        //validator: RegExpValidator{regExp: /[0-9.]+/}
        font.pointSize: Theme.middleSize
        text: amount

        Label {
            id: labelUnit1
            width: paintedWidth
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
        anchors.topMargin: Theme.ph(0.02)
        anchors.left: labelAmount.left
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtFee + " :"
    }

    QInput {
        id: labelFeeValue
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
        text: fee
        onInputAccepted: {
            labelFeeValue.inputFocus = false
        }

        Label {
            id: labelUnit2
            width: paintedWidth
            height: parent.height
            anchors.left: labelFeeValue.left
            anchors.leftMargin: labelFeeValue.width + Theme.pw(0.02)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.pointSize: Theme.mediumSize
            color: Theme.lightColor1
            text: coinType
        }
    }

    QButton {
        id: btnReplace
        anchors.top: labelFeeValue.bottom
        anchors.topMargin: Theme.ph(0.07)
        anchors.horizontalCenter: parent.horizontalCenter
        text: Lang.txtReplace
        onClicked: {
            var infee
            var bestFee = agent.getBestFee(coinType)
            var strBestFee = bestFee
            if (agent.isUtxoCoinType(coinType)) {
                strBestFee = Config.coinsAmountString(bestFee, coinType)
                infee = Config.coinsAmountValue(labelFeeValue.text, coinType)
                var ua = parseInt(utxoamount)
                var am = Config.coinsAmountValue(labelAmountValue.text, coinType)
                if (am + infee > ua) {
                    Theme.showToast(Lang.msgAmountGreater + Config.coinsAmountString(ua, coinType))
                    labelAmountValue.inputFocus = true
                    return
                }
            } else if (agent.isWeitCoinType(coinType)) {
                infee = labelFeeValue.text
            } else {
                infee = labelFeeValue.text
            }
            if (infee < bestFee) {
                Theme.showToast(Lang.msgFeeGreater + strBestFee)
                return
            }
            if (labelFeeValue.text <= fee) {
                Theme.showToast(Lang.msgFeeTooSmall)
                return
            }

            labelFeeValue.inputFocus = false
            dialogConfirm.show()
        }
    }

    QDialog {
        id: dialogConfirm
        content.height: Theme.ph(0.33)
        content.anchors.topMargin: Theme.ph(0.3)

        Label {
            id: txtReplaceTip
            text: Lang.txtReplaceTip
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogConfirm.content.width * 0.8
            height: dialogConfirm.content.height * 0.5
            anchors.horizontalCenter: dialogConfirm.content.horizontalCenter
            anchors.top: dialogConfirm.content.top
            anchors.bottom: btnConfirm.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        QButton {
            id: btnConfirm
            text: Lang.txtConfirm
            anchors.left: dialogConfirm.content.left
            anchors.leftMargin: Theme.pw(0.03)
            anchors.bottom: dialogConfirm.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                dialogConfirm.hide()
                pageTransactionReplaced.show()
            }
        }

        QButton {
            id: btnCancel
            text: Lang.txtCancel
            anchors.right: dialogConfirm.content.right
            anchors.rightMargin: Theme.pw(0.03)
            anchors.bottom: dialogConfirm.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                dialogConfirm.hide()
            }
        }
    }

    TransactionReplaced {
        id: pageTransactionReplaced
        anchors.fill: parent
        onBackClicked: {
            _pageTransactionDetail.backClicked()
            _pageReplace.backClicked()
            pageTransactionReplaced.hide()
        }
    }
}
