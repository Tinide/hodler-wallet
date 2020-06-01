import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageAddService
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property int reqID: -1
    property string coinType: "BTC"
    property bool testStatus: false

    signal backClicked()
    signal addClicked()

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        clearInputFocus()
        opacity = 0
        testStatus = false
        actionFadeout.running = true
    }

    function clearInputFocus() {
        inputIP.inputFocus = false
        inputPort.inputFocus = false
        inputUser.inputFocus = false
        inputPass.inputFocus = false
    }

    function testService() {
        var jsonObj = {"params": []}
        reqID = JsonRpc.rpcCall("getblockchaininfo", jsonObj, "",
                                inputIP.text, parseInt(inputPort.text),
                                checkTls.checked, "/",
                                inputUser.text, inputPass.text)
    }

    Connections {
        target: JsonRpc
        onRpcReply: {
            if (id != reqID) {
                return
            }
            try {
                if (reply["error"] !== null) {
                    Theme.showToast(JSON.stringify(reply["error"]))
                } else {
                    Theme.showToast(Lang.txtOK)
                    testStatus = true
                }
            } catch (e) {
                Theme.showToast(e)
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
            target: _pageAddService
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            clearInputFocus()
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtAdd + " " + coinType.toLowerCase() + "d " + Lang.txtService
        iconRightSource: Config.coinIconSource(coinType)
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Item {
        id: labelHelp
        width: Theme.pw(0.9)
        height: Theme.ph(0.05)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter

        Label {
            width: Theme.pw(0.15)
            height: parent.height
            anchors.right: parent.right
            anchors.rightMargin: -Theme.pw(0.06)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            font.pointSize: Theme.hugeSize
            font.family: Theme.fixedFontFamily
            color: Theme.lightColor1
            text: "?"
            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    clearInputFocus()
                    dialogHelp.show()
                }
            }
        }
    }

    Label {
        id: labelIP
        width: Theme.pw(0.3)
        height: Theme.ph(0.06)
        anchors.top: labelHelp.bottom
        //anchors.topMargin: Theme.ph(0.01)
        anchors.left: labelHelp.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        text: "IP / Domain :"

        QInput {
            id: inputIP
            width: Theme.pw(0.4)
            height: Theme.ph(0.06)
            anchors.left: labelIP.right
            anchors.leftMargin: Theme.mm(2)
            echoPasswd: false
        }
    }

    Label {
        id: labelPort
        width: Theme.pw(0.3)
        height: Theme.ph(0.06)
        anchors.top: labelIP.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.left: labelHelp.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        text: "Port :"

        QInput {
            id: inputPort
            width: Theme.pw(0.4)
            height: Theme.ph(0.06)
            anchors.left: labelPort.right
            anchors.leftMargin: Theme.mm(2)
            echoPasswd: false
        }
    }

    QCheckBox {
        id: checkAuth
        anchors.top: labelPort.bottom
        anchors.topMargin: Theme.ph(0.05)
        anchors.left: parent.left
        anchors.leftMargin: Theme.pw(0.2)
        text: "Auth"
    }

    QCheckBox {
        id: checkTls
        anchors.top: labelPort.bottom
        anchors.topMargin: Theme.ph(0.05)
        anchors.left: checkAuth.right
        text: "TLS"
    }

    Label {
        id: labelUser
        visible: checkAuth.checked
        width: Theme.pw(0.3)
        height: Theme.ph(0.06)
        anchors.top: checkTls.bottom
        //anchors.topMargin: Theme.ph(0.01)
        anchors.left: labelHelp.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        text: "User :"

        QInput {
            id: inputUser
            width: Theme.pw(0.4)
            height: Theme.ph(0.06)
            anchors.left: labelUser.right
            anchors.leftMargin: Theme.mm(2)
            echoPasswd: false
            inputHints: Qt.ImhPreferLowercase
        }
    }

    Label {
        id: labelPass
        visible: checkAuth.checked
        width: Theme.pw(0.3)
        height: Theme.ph(0.06)
        anchors.top: labelUser.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.left: labelHelp.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        text: "Pass :"

        QInput {
            id: inputPass
            width: Theme.pw(0.4)
            height: Theme.ph(0.06)
            anchors.left: labelPass.right
            anchors.leftMargin: Theme.mm(2)
            echoPasswd: true
            inputHints: Qt.ImhPreferLowercase
        }
    }

    QButton {
        id: btnTest
        anchors.top: labelPass.bottom
        anchors.topMargin: Theme.ph(0.1)
        anchors.right: parent.right
        anchors.rightMargin: parent.width * 0.53
        text: Lang.txtTest
        onClicked: {
            clearInputFocus()
            testService()
        }
    }

    QButton {
        id: btnAdd
        visible: testStatus
        anchors.top: labelPass.bottom
        anchors.topMargin: Theme.ph(0.1)
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.53
        text: Lang.txtAdd
        onClicked: {
            clearInputFocus()
            Store.addService(coinType, inputIP.text, parseInt(inputPort.text),
                             checkTls.checked, checkAuth.checked,
                             inputUser.text, inputPass.text)
            backClicked()
        }
    }

//    QButton {
//        id: btnDelete
//        anchors.top: labelPass.bottom
//        anchors.topMargin: Theme.ph(0.1)
//        anchors.left: parent.left
//        anchors.leftMargin: parent.width * 0.53
//        text: Lang.txtDelete
//        onClicked: {
//            clearInputFocus()
//        }
//    }

    QDialog {
        id: dialogHelp
        onSpaceClicked: {
            hide()
        }

        Label {
            id: txtHelp
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogHelp.content.width * 0.9
            height: dialogHelp.content.height * 0.9
            anchors.centerIn: dialogHelp.content
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignLeft
            wrapMode: Text.Wrap
            text: Lang.txtDarkServiceIntro
        }
    }
}
