import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageTools
    color: Theme.darkColor6


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
        pageVerify.hide()
        pageCreateQRCode.hide()
        listModel.clear()
        listModel.append({lt: Lang.txtVerifyMessageSign})
        listModel.append({lt: Lang.txtCreateQRCode})
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtTools
    }

    ListModel { id: listModel }
    QList {
        id: listTools
        width: parent.width
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
        model: listModel
        delegate: QListItem {
            width: listTools.width
            height: Theme.ph(0.077)
            leftText: lt
            onClicked: {
                switch (index) {
                case 0:
                    pageVerify.show()
                    break
                case 1:
                    pageCreateQRCode.show()
                    break
                }
            }
        }
    }

    VerifySignature {
        id: pageVerify
        anchors.fill: parent
        onBackClicked: {
            pageVerify.hide()
        }
    }

    CreateQRCode {
        id: pageCreateQRCode
        anchors.fill: parent
        onBackClicked: {
            pageCreateQRCode.hide()
        }
    }
}
