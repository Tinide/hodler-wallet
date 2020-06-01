import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageHelp3
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
            target: _pageHelp3
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtHelp3
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
        anchors.topMargin: Theme.ph(0.03)
        width: Theme.pw(0.4)
        scale: 0.8
        height: width
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: text1
        anchors.top: imageIcon.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignHCenter
        width: Theme.pw(0.9)
        height: Theme.ph(0.1)
        color: Theme.lightColor5
        font.pointSize: Theme.middleSize
        background: Item {}
        wrapMode: Text.Wrap
        text: Lang.txtHelpContent5
    }

    Label {
        id: text2
        anchors.top: text1.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        horizontalAlignment: Text.AlignLeft
        width: Theme.pw(0.9)
        height: Theme.ph(0.2)
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        background: Item {}
        wrapMode: Text.Wrap
        text: Lang.txtHodlerRef
    }
}
