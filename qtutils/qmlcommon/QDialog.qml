import QtQuick 2.12
import QtQuick.Controls 2.12
import Theme 1.0


Item {
    id: _dialog
    visible: false
    width: parent.width
    height: parent.height
    anchors.centerIn: parent
    transformOrigin: Item.Center
    scale: 0.8
    opacity: 0

    property alias content: rectContent

    signal closed()
    signal spaceClicked()
    signal outsideClicked()

    function show() {
        _dialog.visible = true
        opacity = 1
        scale = 1
    }
    function hide() {
        opacity = 0
        scale = 0.8
        actionFadeout.running = true
        _dialog.clip = false
        closed()
    }

    onScaleChanged: {
        if (scale > 0.999) {
            _dialog.clip = true
        }
    }

    Behavior on opacity {
        PropertyAnimation{
            easing.type: Easing.OutBack
            duration: 300
        }
    }

    Behavior on scale {
        PropertyAnimation{
            easing.type: Easing.OutBack
            duration: 300
        }
    }

    SequentialAnimation {
        id: actionFadeout
        running: false

        PauseAnimation { duration: 288 }
        PropertyAction {
            target: _dialog
            property: "visible"
            value: false
        }
    }

    Rectangle {
        id: rectBackground
        width: parent.width
        height: parent.height
        anchors.centerIn: parent
        scale: 2
        color: Theme.darkColor7
        opacity: 0.85
    }

    MouseArea {
        enabled: _dialog.visible
        anchors.fill: parent
        onClicked: {
            hide()
            outsideClicked()
        }
    }

    Rectangle {
        id: rectContent
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: parent.top
        anchors.topMargin: (parent.height - rectContent.height) * 0.25
        width: Theme.pw(0.8)
        height: Theme.ph(0.5)
        color: Theme.lightColor7
        radius: Theme.mm(3)

        MouseArea {
            anchors.fill: parent
            onClicked: { spaceClicked() }
        }
    }
}

