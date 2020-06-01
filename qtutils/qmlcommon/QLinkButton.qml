import QtQuick 2.12
import QtQuick.Controls 2.12
import Theme 1.0


Item {
    id: _linkBtn
    width: Theme.buttonWidth
    height: Theme.buttonHeight

    property alias textVisible: btnText.visible
    property alias text: btnText.text
    property alias textColor: btnText.color
    property alias textAlias: btnText

    signal clicked()

    Label {
        id: btnText
        width: parent.width
        height: paintedHeight + 2
        anchors.verticalCenter: parent.verticalCenter
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        text: "Link"
        color: Theme.lightColor1
        font.pointSize: Theme.baseSize

        Rectangle {
            width: btnText.paintedWidth
            height: 1
            anchors.bottom: parent.bottom
            anchors.horizontalCenter: parent.horizontalCenter
            color: btnText.color
        }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            _linkBtn.clicked()
        }
    }
}

