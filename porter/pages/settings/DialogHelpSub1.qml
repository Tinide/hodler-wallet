import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageHelp1
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
            target: _pageHelp1
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtHelp1
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    Image {
        id: imageIcon
        source: "qrc:/images/PorterIcon.png"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.02)
        width: Theme.pw(0.2)
        height: width
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: text1
        anchors.top: imageIcon.bottom
        anchors.topMargin: Theme.ph(0.04)
        anchors.horizontalCenter: parent.horizontalCenter
        width: Theme.pw(0.9)
        height: Theme.ph(0.7)
        color: Theme.lightColor5
        font.pointSize: Theme.middleSize
        background: Item {}
        wrapMode: Text.Wrap
        text: Lang.txtHelpContent1
    }
}
