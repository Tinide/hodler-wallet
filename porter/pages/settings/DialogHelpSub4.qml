import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageHelp4
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
            target: _pageHelp4
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtHelp4
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
        contentHeight: {
            var ch = Theme.ph(0.3) - _scroll.height
            for (var i = 0; i < _scroll.children.length; i++) {
                ch += _scroll.children[i].height
            }
            return ch
        }
        clip: true

        Label {
            id: text1
            anchors.top: parent.top
            anchors.topMargin: Theme.ph(0.02)
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignLeft
            width: Theme.pw(0.9)
            height: paintedHeight
            color: Theme.lightColor5
            font.pointSize: Theme.middleSize
            wrapMode: Text.Wrap
            text: Lang.txtHelpContent6
        }

        Image {
            id: image1
            source: "qrc:/images/Screen5.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: text1.bottom
            anchors.topMargin: Theme.ph(0.02)
            height: Theme.ph(0.25)
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: image2
            source: "qrc:/images/Screen4.png"
            anchors.right: image1.left
            anchors.rightMargin: Theme.pw(0.05)
            anchors.top: text1.bottom
            anchors.topMargin: Theme.ph(0.02)
            height: Theme.ph(0.25)
            fillMode: Image.PreserveAspectFit
        }

        Image {
            id: image3
            source: "qrc:/images/Screen6.png"
            anchors.left: image1.right
            anchors.leftMargin: Theme.pw(0.05)
            anchors.top: text1.bottom
            anchors.topMargin: Theme.ph(0.02)
            height: Theme.ph(0.25)
            fillMode: Image.PreserveAspectFit
        }

        Label {
            id: text2
            anchors.top: image3.bottom
            anchors.topMargin: Theme.ph(0.05)
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignLeft
            width: Theme.pw(0.9)
            height: Theme.ph(0.06)
            color: Theme.lightColor5
            font.pointSize: Theme.middleSize
            wrapMode: Text.Wrap
            text: Lang.txtHelpContent7
        }

        Label {
            id: text3
            anchors.top: text2.bottom
            anchors.topMargin: Theme.ph(0.02)
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignLeft
            width: Theme.pw(0.9)
            height: Theme.ph(0.06)
            color: Theme.lightColor5
            font.pointSize: Theme.middleSize
            wrapMode: Text.Wrap
            text: Lang.txtHelpContent8
        }

        Image {
            id: imageScan
            source: Store.Theme > 1 ? "qrc:/images/QRScanIconDark.png" : "qrc:/images/QRScanIcon.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: text3.bottom
            anchors.topMargin: Theme.ph(0.02)
            height: Theme.ph(0.08)
            fillMode: Image.PreserveAspectFit
        }

        Label {
            id: text4
            anchors.top: imageScan.bottom
            anchors.topMargin: Theme.ph(0.04)
            anchors.horizontalCenter: parent.horizontalCenter
            horizontalAlignment: Text.AlignLeft
            width: Theme.pw(0.9)
            height: Theme.ph(0.06)
            color: Theme.lightColor5
            font.pointSize: Theme.middleSize
            wrapMode: Text.Wrap
            text: Lang.txtHelpContent9
        }
    }
}
