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

    Label {
        id: textVer
        text: Lang.appVersion
        color: Theme.lightColor1
        font.pointSize: Theme.smallSize
        anchors.right: parent.right
        anchors.rightMargin: 2 * Theme.dp
        anchors.top: parent.top
        anchors.topMargin: 2 * Theme.dp
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        width: paintedWidth
        height: paintedHeight
    }

    Image {
        id: imageIcon
        source: "qrc:/images/PorterIcon.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: Theme.ph(0.2)
        width: Theme.pw(0.3)
        height: width
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: textApp
        text: Lang.appTitle
        color: Theme.lightColor1
        font.pointSize: Theme.largeSize
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: imageIcon.bottom
        anchors.topMargin: textApp.paintedHeight * 2
    }
}
