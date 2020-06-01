import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageAddressDetail
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property string coinType: "BTC"
    property string address: "-"
    property alias label: inputLabel.text
    property string balance: "-"
    property string pending: "-"
    property string total: "-"
    property string rawUtxo: "[]"
    property int utxoCount: 0

    signal backClicked()
    signal labelDataChanged()

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        dialogUtxo.hide()
        inputLabel.inputFocus = false
        labelAddress.inputFocus = false
        opacity = 0
        actionFadeout.running = true

        label = ""
        address = ""
        rawUtxo = "[]"
        utxoCount = 0
    }

    function loadAddressData(addr,lb,ct,ba,pe,to,data) {
        coinType = ct
        address = addr
        balance = ba
        pending = pe
        total = to
        rawUtxo = data
        if (lb !== Lang.txtNoLabel) {
            label = lb
        }
        agent.syncBalance(coinType, address)
    }

    Connections {
        target: Config
        onBalanceResult: {
            if (addr != address) {
                return
            }
            if (agent.isUtxoCoinType(coinType)) {
                var bala = Config.coinsAmountValue(ba, coinType)
                balance = Config.coinsAmountString(bala, coinType)
                var tt = Config.coinsAmountValue(ta, coinType)
                total = Config.coinsAmountString(tt, coinType)
                try {
                    var jdata = JSON.parse(dat)
                    utxoCount = jdata.length
                } catch (e) {
                    Theme.showToast(e)
                }
            } else {
                balance = ba
                total = ta
            }

            _pageAddressDetail.balance = balance
            _pageAddressDetail.pending = pa
            _pageAddressDetail.total = total
            _pageAddressDetail.rawUtxo = dat
            btnSync.enabled = true
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
            target: _pageAddressDetail
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            inputLabel.inputFocus = false
            labelAddress.inputFocus = false
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtAddressDetail
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelAddressTip
        width: Theme.pw(0.9)
        height: Theme.ph(0.05)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        elide: Text.ElideRight
        text: Config.coinName(coinType) + " " + Lang.txtAddress + " :"
    }

    QTextField {
        id: labelAddress
        width: Theme.pw(0.9)
        height: Theme.ph(0.10)
        anchors.top: labelAddressTip.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: Theme.baseSize
        textColor: Config.coinColor(coinType)
        text: address
    }

    Item {
        id: itemLabel
        width: Theme.pw(0.9)
        height: Theme.ph(0.06)
        anchors.top: labelAddress.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            id: labelLabel
            width: Theme.pw(0.12)
            height: parent.height
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.pointSize: Theme.baseSize
            color: Theme.lightColor1
            elide: Text.ElideRight
            text: Lang.txtLabel + " :"
        }

        QInput {
            id: inputLabel
            echoPasswd: false
            height: parent.height
            anchors.left: labelLabel.right
            anchors.right: btnSave.left
            anchors.verticalCenter: parent.verticalCenter
            placeText: Lang.txtNoLabel
        }

        QButton {
            id: btnSave
            width: Theme.pw(0.12)
            height: parent.height * 0.8
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            text: Lang.txtSave
            onClicked: {
                Store.updateLabel(address, label)
                labelDataChanged()
                Theme.showToast(Lang.txtDone)
            }
        }
    }

    Label {
        id: labelBalanceTip
        width: paintedWidth
        height: Theme.ph(0.06)
        anchors.top: itemLabel.bottom
        anchors.topMargin: Theme.ph(0.06)
        anchors.left: itemLabel.left
        anchors.leftMargin: Theme.pw(0.05)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        text: Lang.txtBalance + " :"
    }

    Label {
        id: labelBalance
        height: Theme.ph(0.06)
        anchors.top: itemLabel.bottom
        anchors.topMargin: Theme.ph(0.06)
        anchors.left: {
            if (labelBalanceTip.paintedWidth > labelPendingTip.paintedWidth) {
                return labelBalanceTip.right
            }
            return labelPendingTip.right
        }
        anchors.leftMargin: Theme.pw(0.02)
        anchors.right: itemLabel.right
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.mediumSize
        color: Config.coinColor(coinType)
        text: balance + " " + coinType
    }

    Label {
        id: labelPendingTip
        width: paintedWidth
        height: Theme.ph(0.06)
        anchors.top: labelBalance.bottom
        anchors.left: itemLabel.left
        anchors.leftMargin: Theme.pw(0.05)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        text: Lang.txtPending + " :"
    }

    Label {
        id: labelPending
        height: Theme.ph(0.06)
        anchors.top: labelBalance.bottom
        anchors.left: {
            if (labelBalanceTip.paintedWidth > labelPendingTip.paintedWidth) {
                return labelBalanceTip.right
            }
            return labelPendingTip.right
        }
        anchors.leftMargin: Theme.pw(0.02)
        anchors.right: itemLabel.right
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.mediumSize
        color: Theme.lightColor1
        text: pending + " " + coinType
    }

    Label {
        id: labelTotalTip
        width: paintedWidth
        height: Theme.ph(0.06)
        anchors.top: labelPending.bottom
        anchors.left: itemLabel.left
        anchors.leftMargin: Theme.pw(0.05)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        text: Lang.txtTotal + " :"
    }

    Label {
        id: labelTotal
        height: Theme.ph(0.06)
        anchors.top: labelPending.bottom
        anchors.left: {
            if (labelBalanceTip.paintedWidth > labelPendingTip.paintedWidth) {
                return labelBalanceTip.right
            }
            return labelPendingTip.right
        }
        anchors.leftMargin: Theme.pw(0.02)
        anchors.right: itemLabel.right
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.mediumSize
        color: Theme.lightColor1
        text: total + " " + coinType

        QLinkButton {
            id: linkUtxo
            visible: utxoCount > 0
            text: "utxo : " + utxoCount
            width: textAlias.paintedWidth
            height: parent.height
            anchors.right: parent.right
            textColor: Theme.lightColor1
            onClicked: {
                dialogUtxo.show()
            }
        }
    }

    QButton {
        id: btnSync
        width: Theme.buttonWidth * 1.2
        anchors.top: labelTotal.bottom
        anchors.topMargin: Theme.ph(0.07)
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.53
        text: Lang.txtSyncBalance
        onClicked: {
            agent.syncBalance(coinType, address)
            btnSync.enabled = false
            delayEnabled.start()
        }
        SequentialAnimation {
            id: delayEnabled
            PauseAnimation {
                duration: 4000
            }
            PropertyAction {
                target: btnSync
                property: "enabled"
                value: true
            }
        }
    }

    QButton {
        id: btnCreate
        width: Theme.buttonWidth * 1.2
        anchors.top: labelTotal.bottom
        anchors.topMargin: Theme.ph(0.07)
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.53
        text: Lang.txtCreateTransaction
        onClicked: {
            pageCreate.balance = _pageAddressDetail.balance
            pageCreate.pending = _pageAddressDetail.pending
            pageCreate.total = _pageAddressDetail.total
            pageCreate.rawUtxo = _pageAddressDetail.rawUtxo
            pageCreate.utxoCount = _pageAddressDetail.utxoCount
            pageCreate.show()
        }
        enabled: {
            var bala = parseFloat(balance)
            if (balance == "-" || bala <= 0) {
                return false
            }
            if (agent.isUtxoCoinType(coinType)) {
                if (utxoCount <= 0) {
                    return false
                }
            }
            if (coinType == "XRP") {
                if (bala < 20.001) {
                    return false
                }
            }
            return true
        }
    }

    QDialog {
        id: dialogUtxo

        Label {
            id: labelUtxo
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogUtxo.content.width
            height: dialogUtxo.content.height * 0.1
            anchors.top: dialogUtxo.content.top
            anchors.horizontalCenter: dialogUtxo.content.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            text: "UTXO"
        }

        QTextField {
            id: textUtxo
            scrollBarAlwaysOn: true
            selectByMouse: true
            width: dialogUtxo.content.width * 0.9
            height: dialogUtxo.content.height * 0.8
            anchors.top: dialogUtxo.content.top
            anchors.topMargin: dialogUtxo.content.height * 0.1
            anchors.left: dialogUtxo.content.left
            anchors.leftMargin: dialogUtxo.content.width * 0.05
            text: rawUtxo
        }

        onClosed: {
            textUtxo.inputFocus = false
        }
    }

    CreateTransaction {
        id: pageCreate
        anchors.fill: parent
        onBackClicked: {
            //_pageAddressDetail.backClicked()
            pageCreate.hide()
        }
    }
}
