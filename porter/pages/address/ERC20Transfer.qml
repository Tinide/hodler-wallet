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
    id: _pageTransfer
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property string balance: "-"
    property string tbalance: "-"
    property string tname: ""
    property string tdecimals: ""
    property string tsymbol: ""
    property string tcontract: ""

    signal backClicked()

    function show(tb,tn,td,ts,tc,ba) {
        tbalance = tb
        tname = tn
        tdecimals = td
        tsymbol = ts
        tcontract = tc
        balance = ba

        visible = true
        opacity = 1

        var bestFee = agent.getBestFee(coinType)
        inputFee.text = "" + bestFee
        labelBestFee.text = Lang.txtEvalFee + bestFee
    }

    function hide() {
        clearFocus()
        opacity = 0
        actionFadeout.running = true
        inputAddress.text = ""
        inputAmount.text = ""
        inputFee.text = ""
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
        var fmp = HDMath.pow(10, tdecimals)
        var fval = HDMath.fdiv(tbalance, fmp)
        if (HDMath.cmp(inputAmount.text, fval) > 0) {
            Theme.showToast(Lang.msgBalanceNotEnough)
            return false
        }
        if (HDMath.cmp(inputFee.text, balance) > 0) {
            Theme.showToast(Lang.msgBalanceNotEnough)
            return false
        }

        address = address.toLowerCase()
        inputAddress.text = inputAddress.text.toLowerCase()

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
            target: _pageTransfer
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
        textTitle: Lang.txtCreateTransaction + " (ERC-20)"
        iconRightSource: Config.coinIconSource("ETH")
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelContract
        width: Theme.pw(0.9)
        height: Theme.ph(0.04)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.smallSize
        color: Theme.lightColor1
        elide: Text.ElideRight
        text: Lang.txtContract + " : " + tcontract
    }

    Label {
        id: labelContractName
        width: Theme.pw(0.9)
        height: Theme.ph(0.05)
        anchors.top: labelContract.bottom
        //anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        elide: Text.ElideRight
        text: Lang.txtContractName + " : " + tname
    }

    Label {
        id: labelFrom
        width: Theme.pw(0.9)
        height: Theme.ph(0.05)
        anchors.top: labelContractName.bottom
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
            text: {
                if (tbalance === "" || tdecimals === "" || tdecimals === "0") {
                    return tbalance + " " + tsymbol
                }
                var fmp = HDMath.pow(10, tdecimals)
                var fval = HDMath.fdiv(tbalance, fmp)
                return Lang.txtBalance + " : " + fval + " " + tsymbol
            }
        }
    }

    Label {
        id: labelFromAddress
        width: Theme.pw(0.91)
        height: Theme.ph(0.04)
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
        anchors.topMargin: Theme.ph(0.03)
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
        width: Theme.pw(0.93)
        height: Theme.ph(0.06)
        anchors.top: labelTo.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: Theme.baseSize
        textColor: Config.coinColor(coinType)
    }

    Label {
        id: labelAmount
        width: Theme.pw(0.2)
        height: Theme.ph(0.06)
        anchors.top: inputAddress.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.left: inputAddress.left
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
        anchors.top: inputAddress.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.left: labelAmount.right
        anchors.leftMargin: Theme.pw(0.02)
        color: Theme.lightColor1
        echoPasswd: false
        validator: DoubleValidator{
            decimals: Number(tdecimals)
            notation: DoubleValidator.StandardNotation
        }
        //validator: RegExpValidator{regExp: /[0-9.]+/}
        placeText: Lang.txtInputAmount
        selectByMouse: true

        Label {
            id: labelUnit1
            width: Theme.pw(0.1)
            height: parent.height
            anchors.left: inputAmount.right
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            font.pointSize: Theme.mediumSize
            color: Theme.lightColor1
            text: tsymbol
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

    ERC20TransferCode {
        id: pageTransaction
        anchors.fill: parent
        onBackClicked: {
            _pageTransfer.backClicked()
            pageTransaction.hide()
        }
    }
}
