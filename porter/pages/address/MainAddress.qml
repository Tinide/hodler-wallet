import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageAddress
    color: Theme.darkColor6

    function cleanPages() {
        dialogConfirm.hide()
        iconLoading.hide()
        pageAddAddress.hide()
        pageAddressDetail.hide()
    }

    Connections {
        target: Config
        onInitHomePage: {
            cleanPages()
            listAddress.loadAddress()
        }
        onLanguageChanged: {
            cleanPages()
            listAddress.loadAddress()
        }
        onScanAddAddress: {
            listAddress.addItem(addr, label, ct)
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtAddresses
        iconRightSource: Store.Theme == 0 ? "qrc:/images/AddIcon.png" : "qrc:/images/AddIconDark.png"
        onRightClicked: {
            pageAddAddress.show()
        }
    }

    ListAddress {
        id: listAddress
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        onItemClicked: {
            pageAddressDetail.loadAddressData(addr, label, ct, ba, pe, to, dat)
            pageAddressDetail.show()
        }
        onItemDelete: {
            dialogConfirm.deleteAddr = addr
            dialogConfirm.show()
        }
    }

    AddAddress {
        id: pageAddAddress
        anchors.fill: parent
        onBackClicked: {
            pageAddAddress.hide()
        }
        onAddClicked: {
            pageAddAddress.hide()
            listAddress.addItem(address, label, ct)
        }
    }

    AddressDetail {
        id: pageAddressDetail
        anchors.fill: parent
        onBackClicked: {
            hide()
        }
        onLabelDataChanged: {
            listAddress.loadAddress()
        }
    }

    QDialog {
        id: dialogConfirm
        content.height: Theme.ph(0.33)
        content.anchors.topMargin: Theme.ph(0.3)
        property string deleteAddr: ""

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
                Store.deleteAddress(dialogConfirm.deleteAddr)
                listAddress.deleteItem()
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
