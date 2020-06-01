import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageHistory
    color: Theme.darkColor6

    Connections {
        target: Config
        onInitHomePage: {
            initPage()
        }
        onHistoryChanged: {
            initPage()
        }
        onLanguageChanged: {
            initPage()
        }
    }

    function initPage() {
        cleanPages()
        listAddressHistory.loadMainHistory()
    }

    function cleanPages() {
        dialogConfirm.hide()
        transactionDetail.hide()
        dialogClearAll.hide()
    }

    QTitleBar {
        id: barTitle
        textRight: Lang.txtClearAll + "    "
        textTitle: Lang.txtHistory
        onRightClicked: {
            dialogClearAll.show()
        }
    }

    ListMainHistory {
        id: listAddressHistory
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        onItemClicked: {
            transactionDetail.loadJsonData(jsonData)
            transactionDetail.show()
        }
        onItemDelete: {
            dialogConfirm.deleteTxid = deltxid
            dialogConfirm.show()
        }
    }

    TransactioinDetail {
        id: transactionDetail
        anchors.fill: parent
        onBackClicked: {
            transactionDetail.hide()
        }
    }

    QDialog {
        id: dialogClearAll
        content.height: Theme.ph(0.3)

        Label {
            id: txtClearAllTip
            text: Lang.txtClearHistoryTip
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogClearAll.content.width * 0.9
            height: paintedHeight
            anchors.top: dialogClearAll.content.top
            anchors.topMargin: dialogClearAll.content.height * 0.25
            anchors.horizontalCenter: dialogClearAll.content.horizontalCenter
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        QButton {
            id: btnConfirm
            text: Lang.txtConfirm
            anchors.left: dialogClearAll.content.left
            anchors.leftMargin: Theme.pw(0.03)
            anchors.bottom: dialogClearAll.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                Store.clearSignHistory()
                listAddressHistory.clearMainHistory()
                dialogClearAll.hide()
            }
        }

        QButton {
            id: btnCancel
            text: Lang.txtCancel
            anchors.right: dialogClearAll.content.right
            anchors.rightMargin: Theme.pw(0.03)
            anchors.bottom: dialogClearAll.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                dialogClearAll.hide()
            }
        }
    }

    QDialog {
        id: dialogConfirm
        content.height: Theme.ph(0.33)
        content.anchors.topMargin: Theme.ph(0.3)
        property int deleteTxid: 0

        Label {
            id: txtDelete
            text: Lang.txtDeleteTip
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogConfirm.content.width * 0.8
            height: dialogConfirm.content.height * 0.5
            anchors.horizontalCenter: dialogConfirm.content.horizontalCenter
            anchors.top: dialogConfirm.content.top
            anchors.bottom: btnDelConfirm.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        QButton {
            id: btnDelConfirm
            text: Lang.txtConfirm
            anchors.left: dialogConfirm.content.left
            anchors.leftMargin: Theme.pw(0.03)
            anchors.bottom: dialogConfirm.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                Store.deleteSignRecord(dialogConfirm.deleteTxid)
                listAddressHistory.deleteItem()
                dialogConfirm.hide()
            }
        }

        QButton {
            id: btnDelCancel
            text: Lang.txtCancel
            anchors.right: dialogConfirm.content.right
            anchors.rightMargin: Theme.pw(0.03)
            anchors.bottom: dialogConfirm.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                dialogConfirm.hide()
            }
        }
    }

    QLoading {
        id: iconLoading
        anchors.fill: parent
    }
}
