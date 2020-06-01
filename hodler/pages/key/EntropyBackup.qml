import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Key 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageEntropyBackup
    color: Theme.darkColor6

    signal backClicked()
    signal nextClicked()

    property int reqID: -1
    property alias nextVisible: btnNext.visible

    function loadEntropy() {
        dialogConfirm.hide()

        if (Key.isGranted() === false) {
            Config.requestPin(null)
            backClicked()
            return
        }
        var entropy = Key.getEntropy()
        if (entropy.length === 0) {
            Theme.showToast("error, no entropy")
            return
        }
        var jsonObj = {"params": [{"entropy": entropy}]}
        reqID = JsonRpc.rpcCall("ENTROPY.EntropyToMnemonic", jsonObj, "",
                                Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
    }

    function clearEntropy() {
        for (var i = 0; i < 24; i++) {
            listModel.set(i, {idx: i+1, word: ""})
        }
    }

    Component.onCompleted: {
        for (var i = 1; i < 25; i++) {
            listModel.append({idx: i, word: ""})
        }
    }

    Connections {
        target: JsonRpc
        onRpcReply: {
            if (id != reqID) {
                return
            }
            if (reply["error"] !== null) {
                Theme.showToast("EntropyToMnemonic: " + reply["error"])
                return
            }
            var mnem = reply["result"]["mnem"]
            var arr = mnem.split(" ")
            for (var i = 0; i < arr.length; i++) {
                listModel.set(i, {idx: i+1, word: arr[i]})
            }
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtBackupRootKey
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
            clearEntropy()
        }
    }

    Label {
        id: labelTip
        width: Theme.pw(0.9)
        height: paintedHeight
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.02)
        anchors.horizontalCenter: parent.horizontalCenter
        color: Theme.lightColor5
        font.pointSize: Theme.baseSize
        text: Lang.txtBackupRootKeyTip
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
    }

    ListModel { id: listModel }
    Label {
        id: labelHidden
        visible: false
        font.pointSize: Theme.middleSize
        font.family: Theme.fixedFontFamily
        text: "L"
    }
    GridView {
        id: listMnem
        clip: true
        cellWidth: Theme.pw(0.39)
        cellHeight: labelHidden.paintedHeight * 1.2
        anchors.left: parent.left
        anchors.leftMargin: Theme.pw(0.15)
        anchors.right: parent.right
        anchors.rightMargin: Theme.pw(0.05)
        anchors.top: labelTip.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.bottom: btnNext.top
        anchors.bottomMargin: Theme.ph(0.02)
        ScrollBar.vertical: ScrollBar {}
        model: listModel
        delegate: Label {
            width: Theme.pw(0.42)
            height: labelHidden.paintedHeight * 1.2
            font.family: Theme.fixedFontFamily
            font.pointSize: Theme.middleSize
            color: Theme.lightColor1
            text: ""+idx+"."+(idx<10?"  ":" ")+word
        }
    }

    QButton {
        id: btnNext
        text: Lang.txtNext
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.ph(0.05)
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            dialogConfirm.show()
        }
    }

    QDialog {
        id: dialogConfirm
        content.height: Theme.ph(0.33)
        content.anchors.topMargin: Theme.ph(0.3)

        Label {
            id: txtBackupMnemTip
            text: Lang.txtBackupMnemonicTip
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
                _pageEntropyBackup.nextClicked()
                clearEntropy()
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
}
