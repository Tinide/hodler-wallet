import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageCreateQRCode
    color: Theme.darkColor6
    visible: false
    opacity: 0

    signal backClicked()

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        _dialogQR.hide()
        inputText.text = ""
        inputText.inputFocus = false
        opacity = 0
        actionFadeout.running = true
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
            target: _pageCreateQRCode
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            inputText.inputFocus = false
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtCreateQRCode
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Label {
        id: labelAddress
        width: Theme.pw(0.9)
        height: paintedHeight
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: Lang.txtInputTextJson
    }

    QInputField {
        id: inputText
        width: Theme.pw(0.9)
        height: Theme.ph(0.3)
        textColor: Theme.lightColor1
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: labelAddress.bottom
        anchors.topMargin: parent.height * 0.012
        selectByMouse: true
        readOnly: false
        text: ""
    }

    QButton {
        id: btnCreate
        text: Lang.txtCreateQRCode
        anchors.top: inputText.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            if (inputText.text.length > 1024) {
                Theme.showToast(Lang.msgQRSizeOver)
                return
            }

            inputText.inputFocus = false
            var txt = inputText.text
            try {
                var json = JSON.parse(txt)
                txt = JSON.stringify(json)
                //console.info("json to QRCode")
            } catch (e) {
                //console.info("text to QRCode")
            }
            qrCode.qrdata = txt
            _dialogQR.show()
        }
    }

    QDialog {
        id: _dialogQR
        content.width: 0
        content.height: 0

        QRCode {
            id: qrCode
            width: Theme.pw(0.9) > Theme.ph(0.9) ? Theme.ph(0.9) : Theme.pw(0.9)
            height: width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        Connections {
            target: Config
            onHideHomeBar: {
                if (_dialogQR.visible) {
                    _dialogQR.hide()
                }
            }
        }
    }
}
