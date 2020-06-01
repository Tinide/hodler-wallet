import QtQuick 2.12
import QtQuick.Controls 2.12
import Theme 1.0


Rectangle {
    id: _btn
    width: Theme.buttonWidth
    height: Theme.buttonHeight
    radius: _btn.height * 0.2
    color: Theme.darkColor2
    opacity: maxOpacity
    clip: true

    property real minOpacity: 0.75
    property real maxOpacity: 1
    property alias textVisible: btnText.visible
    property bool bgColorHoverdChange: true
    property alias text: btnText.text
    property alias textAlias: btnText

    signal clicked()

    Label {
        id: btnText
        width: parent.width
        height: parent.height
        anchors.fill: parent
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "Button"
        color: Theme.lightColor1
        font.pointSize: Theme.baseSize
    }

    MouseArea {
        hoverEnabled: true
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onEntered: {
            if (parent.bgColorHoverdChange && _btn.enabled) {
                animEnter.start()
            }
        }
        onExited: {
            if (parent.bgColorHoverdChange && _btn.enabled) {
                animExit.start()
            }
        }
        onClicked: {
            if (_btn.enabled) {
                _btn.clicked()
            }
        }
    }

    OpacityAnimator on opacity {
        id: animEnter
        from: _btn.maxOpacity
        to: _btn.minOpacity
        duration: Theme.animateDuration
        running: false
    }
    OpacityAnimator on opacity {
        id: animExit
        from: _btn.minOpacity
        to: _btn.maxOpacity
        duration: Theme.animateDuration
        running: false
    }

    Rectangle {
        id: rectDisable
        radius: _btn.height * 0.2
        anchors.fill: parent
        color: Theme.disableColor
        visible: !_btn.enabled
    }
}

