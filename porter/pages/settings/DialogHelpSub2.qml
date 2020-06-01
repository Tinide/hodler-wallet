import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageHelp2
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
            target: _pageHelp2
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtHelp2
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

        Item {
            id: item1
            width: Theme.pw(0.9)
            height: Theme.ph(0.06)
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: imageIcon
                source: "qrc:/images/AddressIcon.png"
                anchors.left: parent.left
                height: parent.height
                width: height
                fillMode: Image.PreserveAspectFit
            }

            Label {
                id: text1
                anchors.left: imageIcon.right
                anchors.leftMargin: Theme.pw(0.03)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                color: Theme.lightColor5
                font.pointSize: Theme.middleSize
                background: Item {}
                wrapMode: Text.Wrap
                text: Lang.txtHelpContent2
            }
        }

        Image {
            id: image1
            source: "qrc:/images/Screen2.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: item1.bottom
            anchors.topMargin: Theme.ph(0.01)
            height: Theme.ph(0.4)
            fillMode: Image.PreserveAspectFit
        }

        Item {
            id: item2
            width: Theme.pw(0.9)
            height: Theme.ph(0.06)
            anchors.top: image1.bottom
            anchors.topMargin: Theme.ph(0.03)
            anchors.horizontalCenter: parent.horizontalCenter

            Image {
                id: imagePorter
                source: "qrc:/images/PorterIcon.png"
                anchors.left: parent.left
                height: parent.height
                width: height
                fillMode: Image.PreserveAspectFit
            }

            Label {
                id: text2
                anchors.left: imagePorter.right
                anchors.leftMargin: Theme.pw(0.03)
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                horizontalAlignment: Text.AlignLeft
                color: Theme.lightColor5
                font.pointSize: Theme.middleSize
                background: Item {}
                wrapMode: Text.Wrap
                text: Lang.txtHelpContent3
            }
        }

        Image {
            id: image2
            source: "qrc:/images/Screen3.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: item2.bottom
            anchors.topMargin: Theme.ph(0.01)
            height: Theme.ph(0.4)
            fillMode: Image.PreserveAspectFit
        }
    }
}
