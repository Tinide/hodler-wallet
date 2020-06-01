import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


QDialog {
    id: _dialogTheme
    anchors.fill: parent
    content.height: Theme.ph(0.28)


    signal themeClicked(int idx)

    Connections {
        target: Config
        onInitHomePage: {
            initPage()
        }
        onLanguageChanged: {
            initPage()
        }
    }

    function initPage() {
        modelTheme.clear()
        modelTheme.append({theme: Lang.txtDark})
        modelTheme.append({theme: Lang.txtDarkWarm})
        modelTheme.append({theme: Lang.txtLight})
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            _dialogTheme.hide()
        }
    }

    ListModel { id: modelTheme }
    ListView {
        id: listTheme
        width: content.width * 0.8
        height: content.height * 0.85
        anchors.centerIn: content
        model: modelTheme
        clip: true
        ScrollBar.vertical: ScrollBar {}
        delegate: Item {
            width: listTheme.width
            height: Theme.ph(0.077)

            Label {
                id: labelName
                height: parent.height
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: theme
                font.pointSize: Theme.middleSize
                color: Theme.darkColor2
            }

            Image {
                id: imgLine
                width: parent.width
                height: 4
                anchors.bottom: parent.bottom
                source: "qrc:/common/image/GradientBlue.png"
                mipmap: true
                fillMode: Image.Stretch
                visible: index < 2
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    themeClicked(index)
                }
            }
        }
    }
}
