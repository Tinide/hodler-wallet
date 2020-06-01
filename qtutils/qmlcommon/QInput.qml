import QtQuick 2.9
import QtQuick.Controls 2.12
import Theme 1.0


Item {
    id: _input
    width: Theme.buttonWidth
    height: Theme.buttonHeight

    property string placeText: ""
    property alias text: inputText.text
    property alias inputFocus: inputText.focus
    property alias inputHints: inputText.inputMethodHints
    property alias validator: inputText.validator
    property alias font: inputText.font
    property bool echoPasswd: true
    property real bottomLineMargin: 4
    property real pointSize: Theme.middleSize
    property alias underlineColor: underLine.color
    property alias color: inputText.color
    property alias selectByMouse: inputText.selectByMouse

    signal inputEdited()
    signal inputAccepted()

    TextField {
        id: inputText
        color: Theme.lightColor1
        inputMethodHints: Qt.ImhPreferNumbers
        selectByMouse: true
        selectionColor: Theme.darkColor5
        selectedTextColor: Theme.lightColor1
        echoMode: echoPasswd ? TextInput.Password : TextInput.Normal
        background: Item {
            anchors.fill: parent
            Rectangle {
                id: underLine
                width: parent.width
                height: 1
                color: Theme.darkColor2
                anchors.bottom: parent.bottom
                anchors.bottomMargin: bottomLineMargin
                anchors.left: parent.left
            }
        }
        anchors.fill: parent
        placeholderText: placeText
        font.pointSize: pointSize
        onTextEdited: {
            inputEdited()
        }
        onAccepted: {
            inputAccepted()
        }
    }

}
