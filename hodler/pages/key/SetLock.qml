import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageSetLock
    color: Theme.darkColor6

    signal clicked()

    MouseArea {
        anchors.fill: parent
        onClicked: {
            inputPin1.inputFocus = false
            inputPin2.inputFocus = false
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtSetPIN
    }

    Image {
        id: imageIcon
        source: "qrc:/images/LockIcon.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.ph(0.13)
        width: Theme.pw(0.16)
        height: width
        fillMode: Image.PreserveAspectFit
    }

    Item {
        id: itemRect
        width: Theme.pw(1)
        anchors.top: imageIcon.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom

        Label {
            id: textPin1
            text: Lang.txtPIN
            color: Theme.lightColor6
            font.pointSize: Theme.mediumSize
            anchors.left: parent.left
            anchors.top: parent.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            width: Theme.pw(0.25)
            height: Theme.buttonHeight
        }

        QInput {
            id: inputPin1
            anchors.left: textPin1.right
            anchors.leftMargin: Theme.pw(0.02)
            anchors.top: textPin1.top
            width: Theme.pw(0.56)
            height: Theme.buttonHeight
            selectByMouse: true
            onInputAccepted: {
                inputPin2.inputFocus = true
            }
        }

        Label {
            id: textPin2
            text: Lang.txtRepeat
            color: Theme.lightColor6
            font.pointSize: Theme.mediumSize
            anchors.left: parent.left
            anchors.top: inputPin1.bottom
            anchors.topMargin: Theme.ph(0.03)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            width: Theme.pw(0.25)
            height: Theme.buttonHeight
        }

        QInput {
            id: inputPin2
            anchors.left: textPin2.right
            anchors.leftMargin: Theme.pw(0.02)
            anchors.top: textPin2.top
            width: Theme.pw(0.56)
            height: Theme.buttonHeight
            selectByMouse: true
            onInputAccepted: {
                inputPin2.inputFocus = false
            }
        }

        QButton {
            id: btnNext
            text: Lang.txtNext
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: inputPin2.bottom
            anchors.topMargin: Theme.ph(0.07)

            onClicked: {
                inputPin1.inputFocus = false
                inputPin2.inputFocus = false

                if (inputPin1.text != inputPin2.text) {
                    Theme.showToast(Lang.msgPINInconsistent)
                    return
                }
                if (inputPin1.text.length < 6 || inputPin1.text.length > 20) {
                    Theme.showToast(Lang.msgPINInvalidLength)
                    return
                }
                Key.Mac = Key.calcMac(inputPin1.text)
                Key.grantPin(inputPin1.text)
                inputPin1.text = ""
                inputPin2.text = ""
                _pageSetLock.clicked()
            }
        }
    }
}
