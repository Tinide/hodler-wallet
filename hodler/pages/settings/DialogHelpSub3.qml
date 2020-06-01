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

    ScrollView {
        id: _scroll
        width: Theme.pw(1)
        height: Theme.ph(0.9)
        anchors.top: barTitle.bottom
        anchors.topMargin: Theme.ph(0.01)
        anchors.horizontalCenter: parent.horizontalCenter
        contentWidth: width
        contentHeight: text1.height + image1.height + text2.height + image2.height + text3.height + text4.height + text5.height + Theme.ph(0.4)
        clip: true

        Label {
            id: text1
            anchors.top: parent.top
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.pw(0.9)
            height: paintedHeight
            color: Theme.lightColor5
            font.pointSize: Theme.middleSize
            background: Item {}
            wrapMode: Text.Wrap
            text: Lang.txtHelpContent4
        }
        Image {
            id: image1
            source: "qrc:/images/PorterIcon.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: text1.bottom
            width: Theme.pw(0.3)
            //height: width
            fillMode: Image.PreserveAspectFit
        }
        Label {
            id: text2
            anchors.top: image1.bottom
            anchors.topMargin: Theme.ph(0.03)
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.pw(0.9)
            height: paintedHeight
            color: Theme.lightColor5
            font.pointSize: Theme.middleSize
            background: Item {}
            wrapMode: Text.Wrap
            text: Lang.txtHelpContent5
        }
        Image {
            id: image2
            source: "qrc:/images/QRScanIcon.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: text2.bottom
            anchors.topMargin: Theme.ph(0.02)
            width: Theme.pw(0.2)
            //height: width
            fillMode: Image.PreserveAspectFit
        }
        Label {
            id: text3
            anchors.top: image2.bottom
            anchors.topMargin: Theme.ph(0.05)
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.pw(0.9)
            height: paintedHeight
            color: Theme.lightColor5
            font.pointSize: Theme.middleSize
            background: Item {}
            wrapMode: Text.Wrap
            text: Lang.txtHelpContent6
        }
        Label {
            id: text4
            anchors.top: text3.bottom
            anchors.topMargin: Theme.ph(0.03)
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.pw(0.9)
            height: paintedHeight
            color: Theme.lightColor5
            font.pointSize: Theme.middleSize
            background: Item {}
            wrapMode: Text.Wrap
            text: Lang.txtHelpContent7
        }
        Label {
            id: text5
            anchors.top: text4.bottom
            anchors.topMargin: Theme.ph(0.03)
            anchors.horizontalCenter: parent.horizontalCenter
            width: Theme.pw(0.9)
            height: paintedHeight
            color: Theme.lightColor5
            font.pointSize: Theme.middleSize
            background: Item {}
            wrapMode: Text.Wrap
            text: Lang.txtHelpContent8
        }
    }
}
