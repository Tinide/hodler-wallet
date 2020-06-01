import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


QDialog {
    id: _dialogLanguage
    anchors.fill: parent
    content.height: Theme.ph(0.6)


    signal langClicked(int idx)

    Connections {
        target: Config
        onInitHomePage: {
            modelLanguage.clear()
            modelLanguage.append({lang: Lang.txtENUS})
            modelLanguage.append({lang: Lang.txtJAJA})
            modelLanguage.append({lang: Lang.txtKOKO})
            modelLanguage.append({lang: Lang.txtDEDE})
            modelLanguage.append({lang: Lang.txtFRFR})
            modelLanguage.append({lang: Lang.txtITIT})
            modelLanguage.append({lang: Lang.txtPLPL})
            modelLanguage.append({lang: Lang.txtESES})
            modelLanguage.append({lang: Lang.txtAFAF})
            modelLanguage.append({lang: Lang.txtZHTW})
            modelLanguage.append({lang: Lang.txtZHCN})
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            _dialogLanguage.hide()
        }
    }

    ListModel { id: modelLanguage }
    ListView {
        id: listLanguage
        width: content.width * 0.8
        height: content.height * 0.85
        anchors.centerIn: content
        model: modelLanguage
        clip: true
        ScrollBar.vertical: ScrollBar {}
        delegate: Item {
            width: listLanguage.width
            height: Theme.ph(0.077)

            Label {
                id: labelName
                height: parent.height
                anchors.fill: parent
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: lang
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
                visible: index < modelLanguage.count - 1
            }

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    langClicked(index)
                }
            }
        }
    }
}
