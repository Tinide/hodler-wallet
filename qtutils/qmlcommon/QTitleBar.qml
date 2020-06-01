import QtQuick 2.12
import QtQuick.Controls 2.12
import Theme 1.0


Rectangle {
    id: _bar
    clip: true
    width: parent.width
    height: Theme.buttonHeight
    color: Theme.darkColor2

    property string iconLeftSource: ""
    property string textLeft: ""
    property string textTitle: ""
    property string iconRightSource: ""
    property string textRight: ""
    property int curVal: 0
    property int maxVal: 0

    signal leftClicked()
    signal rightClicked()

    MouseArea {
        id: areaLeft
        width: Math.max(txtLeft.paintedWidth, parent.width * 0.18)
        height: parent.height
        anchors.left: parent.left
        onClicked: {
            leftClicked()
        }
    }

    MouseArea {
        id: areaRight
        width: Math.max(txtRight.paintedWidth, parent.width * 0.18)
        height: parent.height
        anchors.right: parent.right
        onClicked: {
            rightClicked()
        }
    }

    Rectangle {
        id: rectProgress
        color: Theme.darkColor1
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        width: {
            if (curVal == 0 || maxVal == 0) {
                return 0
            }
            var w = (curVal / maxVal) * _bar.width
            return w
        }
    }

    Image {
        id: iconLeft
        width: iconLeftSource == "" ? 0 : _bar.height
        height: width
        anchors.left: _bar.left
        source: iconLeftSource
        mipmap: true
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: txtLeft
        width: paintedWidth + Theme.mm(4)
        height: _bar.height
        anchors.verticalCenter: _bar.verticalCenter
        anchors.left: iconLeft.right
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        text: textLeft
    }

    Label {
        id: txtTitle
        width: paintedWidth + Theme.mm(4)
        height: _bar.height
        anchors.centerIn: _bar
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        text: textTitle
    }

    Image {
        id: iconRight
        width: iconRightSource == "" ? 0 : _bar.height
        height: width
        anchors.right: _bar.right
        source: iconRightSource
        mipmap: true
        fillMode: Image.PreserveAspectFit
    }

    Label {
        id: txtRight
        width: paintedWidth + Theme.mm(4)
        height: _bar.height
        anchors.verticalCenter: _bar.verticalCenter
        anchors.right: iconRight.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        text: textRight
    }
}

