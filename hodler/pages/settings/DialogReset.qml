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
    id: _dialogReset
    anchors.fill: parent
    content.height: Theme.ph(0.4)

    signal resetClicked()

    Image {
        id: iconWarning
        width: _dialogReset.content.width * 0.2
        height: width
        anchors.top: _dialogReset.content.top
        anchors.topMargin: Theme.ph(0.02)
        anchors.horizontalCenter: content.horizontalCenter
        source: "qrc:/common/image/IconWarning.png"
        mipmap: true
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: textResetTip
        text: Lang.tipReset
        color: Theme.darkColor2
        font.pointSize: Theme.baseSize
        anchors.top: iconWarning.bottom
        anchors.topMargin: Theme.ph(0.05)
        anchors.horizontalCenter: content.horizontalCenter
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        width: Theme.pw(0.2)
        height: Theme.buttonHeight
    }

    QButton {
        id: btnConfirm
        text: Lang.txtConfirm
        anchors.left: _dialogReset.content.left
        anchors.leftMargin: Theme.pw(0.03)
        anchors.bottom: _dialogReset.content.bottom
        anchors.bottomMargin: Theme.pw(0.03)
        onClicked: {
            resetClicked()
        }
    }

    QButton {
        id: btnCancel
        text: Lang.txtCancel
        anchors.right: _dialogReset.content.right
        anchors.rightMargin: Theme.pw(0.03)
        anchors.bottom: _dialogReset.content.bottom
        anchors.bottomMargin: Theme.pw(0.03)
        onClicked: {
            _dialogReset.hide()
        }
    }
}
