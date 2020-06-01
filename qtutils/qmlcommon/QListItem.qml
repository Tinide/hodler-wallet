import QtQuick 2.9
import QtQuick.Controls 2.12
import Theme 1.0


Rectangle {
    id: _item
    color: Theme.darkColor7

    property string leftText: ""
    property string rightText: ""
    property alias rightIcon: iconRight

    signal clicked()

    Label {
        id: txtLeft
        height: parent.height
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: Theme.pw(0.05)
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        text: leftText
    }

    Label {
        id: iconRight
        height: parent.height
        width: paintedWidth
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: Theme.pw(0.05)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
        font.family: Theme.fixedFontFamily
        text: ">"
    }

    Label {
        id: txtRight
        height: parent.height
        width: paintedWidth
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        anchors.right: iconRight.left
        anchors.rightMargin: Theme.pw(0.05)
        horizontalAlignment: Text.AlignRight
        verticalAlignment: Text.AlignVCenter
        color: Theme.lightColor2
        font.pointSize: Theme.middleSize
        text: rightText
    }

    Rectangle {
        id: lineBottom
        width: parent.width
        height: Theme.mm(0.21)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        color: Theme.darkColor8
    }

    SequentialAnimation {
        id: animationPress
        ColorAnimation {
            target: _item
            property: "color"
            from: Theme.darkColor7
            to: Theme.darkColor8
            duration: 150
        }
        ColorAnimation {
            target: _item
            property: "color"
            from: Theme.darkColor8
            to: Theme.darkColor7
            duration: 140
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            _item.clicked()
        }
        onPressed: {
            animationPress.start()
        }
    }
}
