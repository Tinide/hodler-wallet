import QtQuick 2.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Key 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageUnlock
    anchors.fill: parent
    color: Theme.darkColor6

    property var callback: null

    signal clicked()
    signal allReset()

    MouseArea {
        anchors.fill: parent
        onClicked: {
            inputUnlockPin.inputFocus = false
        }
    }

    Image {
        id: imageIcon
        source: "qrc:/images/KeyIcon.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.ph(0.02)
        width: Theme.pw(0.35)
        height: width
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: textUnlockPin
        text: Lang.txtUnlockTip
        color: Theme.lightColor6
        font.pointSize: Theme.fatterSize
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: imageIcon.bottom
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width * 0.8
        height: Theme.buttonHeight * 0.8
        wrapMode: Text.Wrap
    }

    QInput {
        id: inputUnlockPin
        anchors.top: textUnlockPin.top
        anchors.topMargin: Theme.ph(0.06)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.pw(0.5)
        height: Theme.buttonHeight
        selectByMouse: true
        onInputAccepted: {
            btnConfirm.clicked()
            inputUnlockPin.inputFocus = true
        }
    }

    QButton {
        id: btnConfirm
        text: Lang.txtConfirm
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: inputUnlockPin.bottom
        anchors.topMargin: Theme.ph(0.06)
        property int testCount: 0
        onClicked: {
            inputUnlockPin.inputFocus = false
            if (inputUnlockPin.text.length == 0) {
                return
            }
            testCount++
            var pin = inputUnlockPin.text
            inputUnlockPin.text = ""
            var hmac = Key.calcMac(pin)
            if (Key.verifyMac(hmac) === false) {
                if (testCount >= 30) {
                    Key.setMac("")
                    testCount = 0
                    Theme.showToast(Lang.msgPINReset)
                    _pageUnlock.allReset()
                    return
                }
                if (testCount >= 3) {
                    Theme.showToast(Lang.msgPINErrorMore + testCount)
                    return
                }
                Theme.showToast(Lang.msgPINIncorrect)
                return
            }
            Key.grantPin(pin)
            testCount = 0
            _pageUnlock.clicked()
            sndUnlock.play()
            if (callback != null) {
                callback()
                callback = null
            }
        }
    }

    MediaPlayer {
        id: sndUnlock
        volume: 0.01
        source: "qrc:/media/unlock.mp3"
    }
}
