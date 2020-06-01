import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Key 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageEntropyGenerate
    color: Theme.darkColor6

    signal backClicked()
    signal nextClicked()

    property int reqID: -1

    function clearMemory() {
        txtRandom.text = Key.randomHexString(4096)
        txtEntropy.text = Key.randomHexString(64)
    }

    Connections {
        target: JsonRpc
        onRpcReply: {
            if (id != reqID) {
                return
            }
            if (reply["error"] !== null) {
                Theme.showToast("EntropyGenerate: " + reply["error"])
                return
            }
            Key.srandSeed(reply["result"]["entropy"])
        }
    }

    Component.onCompleted: {
        var jsonObj = {"params": [{"bitsize": 256}]}
        reqID = JsonRpc.rpcCall("ENTROPY.EntropyGenerate", jsonObj, "",
                                Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtGenRootKey
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Item {
        id: rectHand
        width: parent.width
        height: Theme.ph(0.06)
        anchors.top: barTitle.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        Image {
            id: iconHand
            source: "qrc:/images/HandIcon.png"
            width: parent.height * 0.6
            height: width
            x: parent.width * 0.2
            y: parent.height * 0.24
        }
        SequentialAnimation {
            id: iconAnimation
            running: _pageEntropyGenerate.visible
            loops: Animation.Infinite
            ParallelAnimation {
                PropertyAnimation {
                    target: iconHand
                    properties: "opacity"
                    from: 0
                    to: 1
                    duration: 400
                }
                PropertyAnimation {
                    target: iconHand
                    properties: "x"
                    to: rectHand.width * 0.6
                    duration: 1000
                }
            }
            ParallelAnimation {
                PropertyAnimation {
                    target: iconHand
                    properties: "opacity"
                    from: 1
                    to: 0
                    duration: 300
                }
                PropertyAnimation {
                    target: iconHand
                    properties: "x"
                    to: rectHand.width * 0.8
                    duration: 500
                }
            }
            PropertyAction {
                target: iconHand
                property: "x"
                value: rectHand.width * 0.2
            }
            PauseAnimation { duration: 1000 }
        }
    }

    Rectangle {
        id: rectBackground
        color: Theme.darkColor1
        width: Theme.pw(0.93)
        anchors.top: rectHand.bottom
        anchors.bottom: btnNext.top
        anchors.bottomMargin: Theme.ph(0.03)
        anchors.horizontalCenter: parent.horizontalCenter
    }

    Text {
        id: txtRandom
        clip: true
        font.family: Theme.fixedFontFamily
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        anchors.top: rectBackground.top
        anchors.bottom: rectBackground.bottom
        anchors.left: rectBackground.left
        anchors.right: rectBackground.right
        anchors.topMargin: Theme.mm(1)
        anchors.bottomMargin: Theme.mm(1)
        anchors.leftMargin: Theme.mm(1)
        anchors.rightMargin: Theme.mm(1)
        wrapMode: Text.WrapAnywhere
        text: Key.randomHexString(4096)
    }

    MouseArea {
        id: areaRandom
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        hoverEnabled: true
        onPositionChanged: {
            if (areaRandom.pressed) {
                txtRandom.text = Key.randomHexString(4096)
                txtEntropy.text = Key.randomHexString(64)
            }
        }
    }

    Text {
        id: txtHidden
        visible: false
        font.family: txtRandom.font.family
        font.pointSize: txtRandom.font.pointSize
        text: "F"
    }

    Rectangle {
        id: rectEntropy
        anchors.horizontalCenter: txtRandom.horizontalCenter
        anchors.top: txtRandom.top
        anchors.topMargin: ((txtRandom.height - height) * 0.5) + Theme.mm(1)
        width:  (txtHidden.paintedWidth * 16) + 1
        height: (txtHidden.paintedHeight * 4) + 1
        color: Theme.darkColor6
        border.width: 1
        border.color: Theme.lightColor5
        Text {
            id: txtEntropy
            color: Theme.lightColor1
            anchors.fill: parent
            font.family: txtRandom.font.family
            font.pointSize: txtRandom.font.pointSize
            wrapMode: Text.WrapAnywhere
            text: Key.randomHexString(64)
        }
        MouseArea {
            anchors.fill: rectEntropy
            onClicked: {
                dialogModifyEntropy.show()
            }
        }
    }

    QButton {
        id: btnNext
        text: Lang.txtNext
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.ph(0.05)
        onClicked: {
            Key.setEntropy(txtEntropy.text)
            nextClicked()
        }
    }

    QDialog {
        id: dialogModifyEntropy

        onVisibleChanged: {
            if (dialogModifyEntropy.visible) {
                txtFieldEntropy.text = txtEntropy.text
                validateEntropyInput()
            } else {
                txtFieldEntropy.text = ""
                txtFieldEntropy.focus = false
            }
        }

        onSpaceClicked: {
            txtFieldEntropy.focus = false
        }

        function validateEntropyInput() {
            var enLen = txtFieldEntropy.text.length
            txtValidate.text = "" + enLen + " / 64"
            if (enLen !== 64) {
                txtValidate.valide = false
                return
            }
            txtValidate.valide = true
        }

        Label {
            id: txtTitle
            text: Lang.txtModifyEntropy
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogModifyEntropy.content.width
            height: paintedHeight * 3
            anchors.top: dialogModifyEntropy.content.top
            anchors.left: dialogModifyEntropy.content.left
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
        }

        TextField {
            id: txtFieldEntropy
            selectByMouse: true
            selectionColor: Theme.darkColor3
            selectedTextColor: Theme.lightColor1
            color: Theme.lightColor1
            font.pointSize: Theme.middleSize
            font.family: Theme.fixedFontFamily
            width: dialogModifyEntropy.content.width * 0.8
            anchors.top: txtTitle.bottom
            anchors.horizontalCenter: dialogModifyEntropy.content.horizontalCenter
            anchors.bottom: btnConfirm.top
            anchors.bottomMargin: Theme.ph(0.05)
            wrapMode: Text.WrapAnywhere
            background: Rectangle {
                color: Theme.darkColor7
            }
            validator: RegExpValidator{regExp: /[A-Fa-f0-9]+/}
            onTextEdited: {
                var enLen = txtFieldEntropy.text.length
                txtValidate.text = "" + enLen + " / 64"
                if (enLen !== 64) {
                    txtValidate.valide = false
                    return
                }
                txtValidate.valide = true
            }
        }

        Label {
            id: txtValidate
            text: "64 / 64"
            color: valide ? Theme.darkColor2 : Theme.lightColor8
            font.pointSize: Theme.baseSize
            width: dialogModifyEntropy.content.width
            height: paintedHeight
            anchors.top: txtFieldEntropy.bottom
            anchors.right: txtFieldEntropy.right
            verticalAlignment: Text.AlignTop
            horizontalAlignment: Text.AlignRight
            property bool valide: true
        }

        QButton {
            id: btnConfirm
            text: Lang.txtConfirm
            anchors.left: dialogModifyEntropy.content.left
            anchors.leftMargin: Theme.pw(0.03)
            anchors.bottom: dialogModifyEntropy.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                if (txtValidate.valide == false) {
                    Theme.showToast(Lang.msgEntropyIncorrect)
                    return
                }
                txtEntropy.text = txtFieldEntropy.text.toUpperCase()
                dialogModifyEntropy.hide()
            }
        }

        QButton {
            id: btnCancel
            text: Lang.txtCancel
            anchors.right: dialogModifyEntropy.content.right
            anchors.rightMargin: Theme.pw(0.03)
            anchors.bottom: dialogModifyEntropy.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                dialogModifyEntropy.hide()
            }
        }
    }
}
