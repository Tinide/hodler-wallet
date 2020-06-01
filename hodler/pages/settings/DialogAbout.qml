import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageAbout
    color: Theme.darkColor6
    anchors.fill: parent
    visible: false
    opacity: 0


    signal backClicked()

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
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
            target: _pageAbout
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtAbout
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Image {
        id: imageIcon
        source: "qrc:/images/KeyIcon.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
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
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        width: parent.width
        height: Theme.ph(0.03)
    }

    Label {
        id: textCopyright
        anchors.top: textAbout.bottom
        anchors.topMargin: Theme.ph(0.07)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.pw(0.9)
        height: Theme.ph(0.5)
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        background: Item {}
        text: 'Project URL :

https://github.com/yancaitech/hodler-wallet


Copyright © 2020 yancaitech@gmail.com'
    }
}
