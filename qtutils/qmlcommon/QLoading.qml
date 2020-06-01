import QtQuick 2.12
import QtQuick.Controls 2.12
import Theme 1.0


Item {
    id: _loading
    width: Theme.pw(1)
    anchors.top: parent.top
    anchors.bottom: parent.bottom
    anchors.horizontalCenter: parent.horizontalCenter
    opacity: 0
    visible: false

    property string loadingText: ""

    function show() {
        visible = true
        opacity = 1
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
        loadingText = ""
    }

    Behavior on opacity {
        PropertyAnimation{
            easing.type: Easing.InOutQuad
            duration: 400
        }
    }

    SequentialAnimation {
        id: actionFadeout
        running: false

        PauseAnimation { duration: 388 }
        PropertyAction {
            target: _loading
            property: "visible"
            value: false
        }
    }

    Rectangle {
        id: rectBackground
        anchors.fill: parent
        color: Theme.darkColor7
        opacity: 0.78
    }

    Image {
        id: imageLoading
        anchors.centerIn: parent
        width: Math.max(Theme.mm(10), Math.min(parent.width * 0.2, parent.height * 0.2))
        height: width
        source: "qrc:/common/image/Loading.png"
        fillMode: Image.PreserveAspectFit
        mipmap: true
        transformOrigin: Item.Center
        Behavior on rotation {
            PropertyAnimation{
                easing.type: Easing.Linear
                duration: 300
            }
        }
    }

    Label {
        id: labelLoading
        width: parent.width
        height: parent.height
        anchors.centerIn: imageLoading
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        color: Theme.lightColor1
        font.pointSize: Theme.smallSize
        text: loadingText
    }

    Timer {
        running: _loading.visible
        repeat: true
        interval: 300
        onTriggered: {
            imageLoading.rotation -= 90
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
        }
    }
}

