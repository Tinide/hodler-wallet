import QtQuick 2.9
import QtQuick.Controls 2.12
import QtQuick.Layouts 1.12
import Theme 1.0


ScrollView {
    id: _inputField
    clip: true

    property alias text: _textArea.text
    property alias selectByMouse: _textArea.selectByMouse
    property alias inputFocus: _textArea.focus
    property bool scrollBarAlwaysOn: false
    property alias textColor: _textArea.color
    property alias textArea: _textArea

    ScrollBar.vertical.policy: scrollBarAlwaysOn?ScrollBar.AlwaysOn:ScrollBar.AsNeeded

    TextArea {
        id: _textArea
        readOnly: true
        selectByMouse: true
        selectionColor: Theme.darkColor5
        selectedTextColor: Theme.lightColor1
        color: Theme.lightColor1
        font.pointSize: Theme.middleSize
        background: Rectangle {
            color: Theme.darkColor7
        }
        wrapMode: Text.WrapAnywhere
    }
}
