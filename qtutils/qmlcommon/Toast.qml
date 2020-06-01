import QtQuick 2.12
import QtQuick.Controls 2.12
import Theme 1.0


Item {
    id: toast
    anchors.bottom: parent.bottom
    anchors.bottomMargin: height + Theme.pw(0.16)
    anchors.left: parent.left
    anchors.leftMargin: Theme.mm(10)
    anchors.right: parent.right
    anchors.rightMargin: Theme.mm(10)
    height: childrenRect.height
    visible: false
    
    property bool showing: false

    Connections {
        target: Theme
        onShowToast: {
            toast.show(msg)
        }
    }

    function show(message) {
        if (visible) {
            if (message !== label.text) {
                messageQueue.enqueue(message)
            }
        } else {
            label.text = message
            toast.visible = true
            toast.showing = true
        }
    }

    transitions: Transition {
        NumberAnimation {
            properties: "opacity"
            easing.type: Easing.InOutQuad
            duration: 170
        }
    }
    
    onVisibleChanged: {
        if (visible) {
            timer.stop()
            timer.start()
        }
    }
    
    onOpacityChanged: {
        if (opacity == 0) {
            visible = false
            label.text = ""
        }
    }
    
    states: [
        State {
            name: "1"
            when: showing
            PropertyChanges {
                target: toast
                opacity: 1.0
            }
        },
        State {
            name: "2"
            when: !showing
            PropertyChanges {
                target: toast
                opacity: 0.0
            }
        }
    ]

    Timer {
        id: timer
        interval: 2500
        onTriggered: {
            if (!messageQueue.isEmpty()) {
                label.text = messageQueue.dequeue()
                timer.stop()
                timer.start()
            } else {
                toast.showing = false
            }
        }
    }
    
    Rectangle {
        id: childrenRect
        anchors.verticalCenter: label.verticalCenter
        anchors.horizontalCenter: label.horizontalCenter
        width: label.contentWidth + Theme.mm(10)
        height: label.contentHeight + Theme.mm(4)
        radius: hiddenText.contentHeight * 0.35
        color: Theme.lightColor1

        Image {
            id: iconWarning
            anchors.left: parent.left
            anchors.leftMargin: Theme.mm(2)
            anchors.top: parent.top
            anchors.topMargin: Theme.mm(2)
            width: (label.contentHeight / label.lineCount)
            height: width
            source: "qrc:/common/image/IconWarning.png"
            scale: 1.5
        }
    }

    Label {
        id: label
        y: Theme.mm(2)
        width: parent.width
        leftPadding: hiddenText.contentHeight + 4
        anchors.horizontalCenter: parent.horizontalCenter
        font.pointSize: Theme.smallSize
        color: Theme.darkColor7
        wrapMode: Text.Wrap
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    Label {
        id: hiddenText
        text: "hidden"
        font.pointSize: Theme.smallSize
        visible: false
    }
    
    Item {
        id: messageQueue
        property var queue: []
        function isEmpty() {
            return queue.length == 0
        }
        function size() {
            return queue.length
        }
        function enqueue(item) {
            queue.push(item)
        }
        function dequeue() {
            return queue.shift()
        }
        function clear() {
            queue = []
        }
    }
}
