import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
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
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtTransactions
    }

    ListMainHistory {
        id: listAddressHistory
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        onItemClicked: {
            transactionDetail.loadJsonData(ss, jsonData)
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
        id: dialogConfirm
        content.height: Theme.ph(0.33)
        content.anchors.topMargin: Theme.ph(0.3)
        property string deleteTxid: ""

        Label {
            id: txtDelete
            text: Lang.txtDeleteTip
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogConfirm.content.width * 0.8
            height: dialogConfirm.content.height * 0.5
            anchors.horizontalCenter: dialogConfirm.content.horizontalCenter
            anchors.top: dialogConfirm.content.top
            anchors.bottom: btnConfirm.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        QButton {
            id: btnConfirm
            text: Lang.txtConfirm
            anchors.left: dialogConfirm.content.left
            anchors.leftMargin: Theme.pw(0.03)
            anchors.bottom: dialogConfirm.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                Store.deleteTxRecord(dialogConfirm.deleteTxid)
                listAddressHistory.deleteItem()
                dialogConfirm.hide()
            }
        }

        QButton {
            id: btnCancel
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
