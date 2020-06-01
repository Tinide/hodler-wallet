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
    id: _pageAddress
    color: Theme.darkColor6

    property int reqID: -1
    property alias coinType: listAddress.coinType

    function cleanPages() {
        pageAddressDetail.hide()
        dialogCoins.hide()
    }

    Connections {
        target: Config
        onInitHomePage: {
            cleanPages()
            listAddress.loadAddress(Store.DefaultCoinType)
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Config.coinName(coinType)
        textRight: Lang.txtCoinType + "  > "
        iconLeftSource: Config.coinIconSource(coinType)
        onRightClicked: {
            if (listAddress.isbusy) {
                Theme.showToast(Lang.msgBusy)
                return
            }
            dialogCoins.show()
        }
    }

    ListAddress {
        id: listAddress
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        onItemClicked: {
            pageAddressDetail.loadAddressData(ct, addr, m1, m2)
            pageAddressDetail.show()
        }
    }

    AddressDetail {
        id: pageAddressDetail
        anchors.fill: parent
        onBackClicked: {
            hide()
        }
    }

    DialogCoinType {
        id: dialogCoins
        width: parent.width
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        onCoinClicked: {
            if (strCoin != coinType) {
                coinType = strCoin
                Store.DefaultCoinType = strCoin
                listAddress.loadAddress(strCoin)
            }
            hide()
        }
    }

    QLoading {
        id: iconLoading
        anchors.fill: parent
    }
}
