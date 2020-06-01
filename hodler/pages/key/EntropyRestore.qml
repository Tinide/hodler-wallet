import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Key 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageEntropyRestore
    color: Theme.darkColor6

    signal backClicked()
    signal nextClicked()

    property int reqID: -1

    function mnemonicToEntropy() {
        var mnem = ""
        for (var i = 0; i < 24; i++) {
            var prop = listModel.get(i)
            mnem += prop["word"]
            if (i < 23) {
                mnem += " "
            }
        }
        mnem = mnem.toLowerCase()
        var jsonObj = {"params": [{"mnem": mnem}]}
        reqID = JsonRpc.rpcCall("ENTROPY.EntropyFromMnemonic", jsonObj, "",
                                Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
    }

    function clearMnemonic() {
        for (var i = 0; i < 24; i++) {
            listModel.set(i, {idx: i+1, word: "", fa: false})
        }
        btnNext.visible = true
    }

    function checkMnemonicInput() {
        for (var i = 0; i < 24; i++) {
            var prop = listModel.get(i)
            var mnem = prop["word"]
            if (mnem.length === 0) {
                return false
            }
        }
        return true
    }

    Component.onCompleted: {
        for (var i = 1; i < 25; i++) {
            listModel.append({idx: i, word: "", fa: false})
        }
    }

    Connections {
        target: JsonRpc
        onRpcReply: {
            if (id != reqID) {
                return
            }
            if (reply["error"] !== null) {
                Theme.showToast("EntropyFromMnemonic: " + reply["error"])
                btnNext.visible = true
                return
            }
            var entropy = reply["result"]["entropy"]
            if (entropy.length !== 64) {
                Theme.showToast("bad ENTROPY.EntropyFromMnemonic reponse")
                btnNext.visible = true
                return
            }
            if (Key.isGranted() === false) {
                Config.requestPin(null)
                return
            }
            Key.setEntropy(entropy)
            nextClicked()
            clearMnemonic()
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtRestoreRootKey
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
            clearMnemonic()
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
        text: Lang.txtRestoreTip
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    ListModel { id: listModel }
    Label {
        id: labelHidden
        visible: false
        font.pointSize: Theme.smallSize
        text: "L"
    }
    GridView {
        id: listMnem
        clip: true
        cellWidth: Theme.pw(0.42)
        cellHeight: labelHidden.paintedHeight * 1.98
        anchors.left: parent.left
        anchors.leftMargin: Theme.pw(0.1)
        anchors.right: parent.right
        anchors.rightMargin: Theme.pw(0.05)
        anchors.top: labelTip.bottom
        anchors.topMargin: Theme.ph(0.03)
        anchors.bottom: btnNext.top
        anchors.bottomMargin: Theme.ph(0.02)
        ScrollBar.vertical: ScrollBar {}
        model: listModel
        delegate: Item {
            width: Theme.pw(0.42)
            height: labelHidden.paintedHeight * 1.98
            Label {
                id: labelIdx
                width: labelHidden.paintedWidth * 3
                font.pointSize: Theme.smallSize
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                color: Theme.lightColor1
                text: "" + idx + "."
                horizontalAlignment: Text.AlignLeft
                verticalAlignment: Text.AlignVCenter
            }
            QInput {
                id: inputWord
                inputFocus: fa
                inputHints: Qt.ImhPreferLowercase
                validator: RegExpValidator{regExp: /[A-Za-z]+/}
                pointSize: Theme.baseSize
                echoPasswd: false
                bottomLineMargin: 2
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.left: labelIdx.right
                anchors.right: parent.right
                anchors.rightMargin: Theme.pw(0.06)
                text: word
                font.family: Theme.fixedFontFamily
                onInputEdited: {
                    word = inputWord.text
                }
                onInputAccepted: {
                    inputWord.inputFocus = false
                    if (idx < 24) {
                        listModel.set(idx, {fa: true})
                    }
                }
            }
        }
    }

    QButton {
        id: btnNext
        text: Lang.txtNext
        anchors.bottom: parent.bottom
        anchors.bottomMargin: Theme.ph(0.035)
        anchors.horizontalCenter: parent.horizontalCenter
        onClicked: {
            if (checkMnemonicInput() === false) {
                Theme.showToast(Lang.msgMnemonicIncorrect)
                return
            }
            btnNext.visible = false
            mnemonicToEntropy()
        }
    }
}
