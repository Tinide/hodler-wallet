import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Item {
    id: _listAddress

    property bool isbusy: iconLoading.visible

    signal itemClicked(string addr, string label, string ct, string ba, string pe, string to, string dat)
    signal itemDelete(string addr)

    function clearList() {
        modelAddr.clear()
    }

    function loadAddress() {
        clearList()

        var json
        var addrlist = Store.queryAddress()
        try {
            json = JSON.parse(addrlist)
        } catch (e) {
            Theme.showToast(Lang.msgBadDataStore)
            Store.clearStore()
        }

        var count = json.length
        for (var i = 0; i < count; i++) {
            var item = json[i]
            var coinT = item["coinType"]
            var label = item["label"]
            if (label === "") {
                label = Lang.txtNoLabel
            }
            var address = item["addr"]
            modelAddr.append({tt: coinT, lb: label, addr: address})
        }
    }

    function addItem(address, label, ct) {
        if (label === "") {
            label = Lang.txtNoLabel
        }
        modelAddr.append({tt: ct, lb: label, addr: address})
        listAddr.currentIndex = modelAddr.count - 1
    }

    function deleteItem() {
        modelAddr.remove(listAddr.delCandidate)
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
        property int delCandidate: -1
        model: modelAddr
        add: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "opacity";
                    from: 0
                    to: 1
                    easing.type: Easing.Linear
                    duration: 270
                }
                PropertyAnimation {
                    property: "x"
                    from: listAddr.width * 0.3
                    easing.type: Easing.OutBack
                    duration: 600
                }
            }
        }
//        remove: Transition {
//            ParallelAnimation {
//                PropertyAnimation {
//                    property: "opacity";
//                    from: 1
//                    to: 0
//                    easing.type: Easing.Linear
//                    duration: 270
//                }
//                PropertyAnimation {
//                    property: "height";
//                    to: 0
//                    easing.type: Easing.OutCubic
//                    duration: 315
//                }
//            }
//        }
        delegate: ItemAddress {
            width: listAddr.width
            height: Theme.ph(0.077)
            address: addr
            label: lb
            tokenType: tt
            onClicked: {
                itemClicked(addr, lb, tt, balance, pending, total, dat)
            }
            onDeleted: {
                listAddr.delCandidate = index
                itemDelete(addr)
            }
        }
        footer: Item {
            width: listAddr.width
            height: bottomBar.height * 0.36
        }
    }
}
