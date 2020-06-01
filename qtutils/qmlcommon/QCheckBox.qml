import QtQuick 2.12
import QtQuick.Controls 2.12
import Theme 1.0


Item {
    id: _check
    width: Theme.buttonWidth
    height: Theme.buttonHeight
    opacity: maxOpacity

    property bool checked: true
    property real minOpacity: 0.75
    property real maxOpacity: 1
    property bool bgColorHoverdChange: true
    property string text: "Check"
    property alias textAlias: btnText

    signal clicked()

    Rectangle {
        id: rectCheck
        height: btnText.paintedHeight
        width: height
        anchors.verticalCenter: parent.verticalCenter
        color: "transparent"
        border.width: 1
        border.color: Theme.lightColor1

        Image {
            visible: checked
            anchors.fill: parent
            source: "qrc:/common/image/Check.png"
            fillMode: Image.PreserveAspectFit
        }
    }

    Label {
        id: btnText
        height: parent.height
        anchors.left: rectCheck.right
        anchors.leftMargin: Theme.mm(2)
        anchors.right: parent.right
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter
        text: _check.text
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor

        onPressed: {
            if (parent.bgColorHoverdChange) {
                animEnter.start()
            }
        }
        onReleased: {
            if (parent.bgColorHoverdChange) {
                animExit.start()
            }
        }
        onClicked: {
            checked = !checked
            _check.clicked()
        }
    }

    OpacityAnimator on opacity {
        id: animEnter
        from: _check.maxOpacity
        to: _check.minOpacity
        duration: Theme.animateDuration
        running: false
    }
    OpacityAnimator on opacity {
        id: animExit
        from: _check.minOpacity
        to: _check.maxOpacity
        duration: Theme.animateDuration
        running: false
    }
}

