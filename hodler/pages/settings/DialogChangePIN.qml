import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


QDialog {
    id: _dialogPIN
    anchors.fill: parent
    content.height: Theme.ph(0.5)


    onVisibleChanged: {
        if (_dialogPIN.visible == false) {
            inputOldPIN.text = ""
            inputNewPIN.text = ""
            inputRepeat.text = ""
            inputOldPIN.inputFocus = false
            inputNewPIN.inputFocus = false
            inputRepeat.inputFocus = false
        }
    }

    MouseArea {
        anchors.fill: _dialogPIN.content
        onClicked: {
            inputOldPIN.inputFocus = false
            inputNewPIN.inputFocus = false
            inputRepeat.inputFocus = false
        }
    }

    Label {
        id: txtTitle
        text: Lang.txtChangePin
        color: Theme.darkColor2
        font.pointSize: Theme.mediumSize
        width: _dialogPIN.content.width
        height: paintedHeight * 3
        anchors.top: _dialogPIN.content.top
        anchors.left: _dialogPIN.content.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        id: textOldPIN
        text: Lang.txtOldPIN
        color: Theme.darkColor2
        font.pointSize: Theme.baseSize
        anchors.left: content.left
        anchors.top: txtTitle.bottom
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        width: Theme.pw(0.2)
        height: Theme.buttonHeight
    }

    QInput {
        id: inputOldPIN
        anchors.left: textOldPIN.right
        anchors.leftMargin: Theme.pw(0.02)
        anchors.top: textOldPIN.top
        width: Theme.pw(0.5)
        height: Theme.buttonHeight
        color: Theme.darkColor2
        selectByMouse: true
        onInputAccepted: {
        }
    }

    Label {
        id: textNewPIN
        text: Lang.txtNewPIN
        color: Theme.darkColor2
        font.pointSize: Theme.baseSize
        anchors.left: content.left
        anchors.top: inputOldPIN.bottom
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        width: Theme.pw(0.2)
        height: Theme.buttonHeight
    }

    QInput {
        id: inputNewPIN
        anchors.left: textNewPIN.right
        anchors.leftMargin: Theme.pw(0.02)
        anchors.top: textNewPIN.top
        width: Theme.pw(0.5)
        height: Theme.buttonHeight
        color: Theme.darkColor2
        selectByMouse: true
        onInputAccepted: {
        }
    }

    Label {
        id: textRepeat
        text: Lang.txtRepeat
        color: Theme.darkColor2
        font.pointSize: Theme.baseSize
        anchors.left: content.left
        anchors.top: inputNewPIN.bottom
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        width: Theme.pw(0.2)
        height: Theme.buttonHeight
    }

    QInput {
        id: inputRepeat
        anchors.left: textRepeat.right
        anchors.leftMargin: Theme.pw(0.02)
        anchors.top: textRepeat.top
        width: Theme.pw(0.5)
        height: Theme.buttonHeight
        color: Theme.darkColor2
        selectByMouse: true
        onInputAccepted: {
        }
    }

    QButton {
        id: btnConfirm
        text: Lang.txtConfirm
        anchors.left: _dialogPIN.content.left
        anchors.leftMargin: Theme.pw(0.03)
        anchors.bottom: _dialogPIN.content.bottom
        anchors.bottomMargin: Theme.pw(0.03)
        property int testCount: 0
        onClicked: {
            if (   inputOldPIN.text == ""
                || inputNewPIN.text == ""
                || inputRepeat.text == "") {
                Theme.showToast(Lang.msgInputEmpty)
                return
            }
            if (inputNewPIN.text != inputRepeat.text) {
                Theme.showToast(Lang.msgPINInconsistent)
                return
            }
            if (inputNewPIN.text.length < 6 || inputNewPIN.text.length > 20) {
                Theme.showToast(Lang.msgPINInvalidLength)
                return
            }

            testCount++
            var hmac = Key.calcMac(inputOldPIN.text)
            if (Key.verifyMac(hmac) === false) {
                if (testCount >= 30) {
                    Key.setMac("")
                    testCount = 0
                    Theme.showToast(Lang.msgPINReset)
                    return
                }
                if (testCount >= 3) {
                    Theme.showToast(Lang.msgPINErrorMore + testCount)
                    return
                }
                Theme.showToast(Lang.msgPINIncorrect)
                return
            }
            Key.grantPin(inputOldPIN.text)
            Key.changePin(inputNewPIN.text)
            Key.grantPin(inputNewPIN.text)

            testCount = 0
            _dialogPIN.hide()

            Theme.showToast(Lang.msgChangePINOK)
        }
    }

    QButton {
        id: btnCancel
        text: Lang.txtCancel
        anchors.right: _dialogPIN.content.right
        anchors.rightMargin: Theme.pw(0.03)
        anchors.bottom: _dialogPIN.content.bottom
        anchors.bottomMargin: Theme.pw(0.03)
        onClicked: {
            _dialogPIN.hide()
        }
    }
}
