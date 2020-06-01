import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageSplash
    anchors.fill: parent
    color: Theme.darkColor6

    signal clicked()

    MouseArea { anchors.fill: parent }

    Image {
        id: imageIcon
        source: "qrc:/images/KeyIcon.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.ph(0.07)
        width: Theme.pw(0.4)
        height: width
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: textAbout
        text: Lang.appTitle + " " + Lang.appVersion
        color: Theme.lightColor1
        font.pointSize: Theme.largeSize
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: imageIcon.bottom
        anchors.topMargin: Theme.ph(0.02)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        height: Theme.ph(0.03)
    }

    Label {
        id: textWarning
        text: Lang.txtWarning
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: textAbout.bottom
        anchors.topMargin: Theme.ph(0.01)
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        wrapMode: Text.Wrap
        width: Theme.pw(0.7)
        height: Theme.ph(0.3)
    }

    QButton {
        id: btnConfirm
        text: Lang.txtConfirm
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: textWarning.bottom
        anchors.topMargin: Theme.ph(0.01)
        onClicked: {
            _pageSplash.clicked()
        }
    }
}
