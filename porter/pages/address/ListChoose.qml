import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _listAddress
    color: Theme.darkColor6

    property bool isbusy: iconLoading.visible

    signal itemClicked(string addr)
    signal itemDelete(string addr)

    function clearList() {
        modelAddr.clear()
    }

    function loadAddress() {
        clearList()

        var json
        var addrlist = Store.queryAddress(coinType)
        try {
            json = JSON.parse(addrlist)
        } catch (e) {
            Theme.showToast(Lang.msgBadDataStore)
            Store.clearStore()
            return
        }

        var count = json.length
        for (var i = 0; i < count; i++) {
            var item = json[i]
            var coinT = item["coinType"]
            var label = item["label"]
            if (label === "") {
                label = Lang.txtNoLabel
            }
            var addr = item["addr"]
            if (addr !== address) {
                modelAddr.append({tt: coinT, lb: label, addr: addr})
            }
        }
    }

    ListModel {
        id: modelAddr
    }

    ListView {
        id: listAddr
        clip: true
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        ScrollBar.vertical: ScrollBar {}
        model: modelAddr
        delegate: ItemChoose {
            width: listAddr.width
            height: Theme.ph(0.077)
            address: addr
            label: lb
            tokenType: tt
            onClicked: {
                itemClicked(addr)
            }
        }
    }
}
