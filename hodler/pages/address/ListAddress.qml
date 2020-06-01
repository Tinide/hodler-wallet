import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


Item {
    id: _listAddress

    property int reqID: -1
    property string coinType: "BTC"
    property bool isbusy: iconLoading.visible

    signal itemClicked(string ct, string addr, int m1, int m2)

    function clearList() {
        reqID = -1
        modelAddr.clear()
    }

    function loadAddress(cointype) {
        iconLoading.show()
        clearList()

        coinType = cointype

        var count = Store.getAddressCount(coinType)
        iconLoading.loadingText = "0 / " + count

        if (count > Config.addrPageItems) {
            count = Config.addrPageItems
        }
        var entropy = Key.getEntropy()
        var jsonObj = {"params": [{
                           "entropy": entropy,
                           "seed": Config.seed,
                           "m1": Config.coinsM1(coinType),
                           "m2": Config.m2,
                           "count": count,
                           "compresspubkey": Config.compressPubkey,
                           "mainnet": Config.mainnet
                        }]}
        reqID = JsonRpc.rpcCall(Config.entropyAddressMethod(coinType), jsonObj, "",
                                Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
    }

    function loadAddressNextPage() {
        var count = Store.getAddressCount(coinType)
        var dcount = count - modelAddr.count
        if (dcount < Config.addrPageItems) {
            count = dcount
        } else {
            count = Config.addrPageItems
        }
        var entropy = Key.getEntropy()
        var jsonObj = {"params": [{
                           "entropy": entropy,
                           "seed": Config.seed,
                           "m1": Config.coinsM1(coinType),
                           "m2": modelAddr.count,
                           "count": count,
                           "compresspubkey": Config.compressPubkey,
                           "mainnet": Config.mainnet
                        }]}
        reqID = JsonRpc.rpcCall(Config.entropyAddressMethod(coinType), jsonObj, "",
                                Config.rpcLocal, Config.rpcLocalPort, Config.rpcLocalTls)
    }

    Connections {
        target: JsonRpc
        onRpcReply: {
            if (id != reqID) {
                return
            }
            if (reply["error"] !== null) {
                iconLoading.hide()
                Theme.showToast("EntropyToAddress: " + reply["error"])
                return
            }
            var addrs = reply["result"]["addresses"]
            var lastIndex = 0
            for (var addr in addrs) {
                if (coinType == "EOS") {
                    modelAddr.append({   address: addrs[addr]["pubkey1"] + "," + addrs[addr]["pubkey2"],
                                         m1: addrs[addr]["m1"],
                                         m2: addrs[addr]["m2"]})
                    Store.addAddress(addrs[addr]["pubkey1"], addrs[addr]["m1"], addrs[addr]["m2"])
                    Store.addAddress(addrs[addr]["pubkey2"], addrs[addr]["m1"], addrs[addr]["m2"])
                } else {
                    modelAddr.append({   address: addrs[addr]["address"],
                                         m1: addrs[addr]["m1"],
                                         m2: addrs[addr]["m2"]})
                    Store.addAddress(addrs[addr]["address"], addrs[addr]["m1"], addrs[addr]["m2"])
                }
                lastIndex = addrs[addr]["m2"]
            }
            var count = Store.getAddressCount(coinType)
            iconLoading.loadingText = "" + (lastIndex+1) + " / " + count
            if (lastIndex + 1 >= count) {
                iconLoading.hide()
                return
            }
            loadAddressNextPage()
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
        remove: Transition {
            ParallelAnimation {
                PropertyAnimation {
                    property: "opacity";
                    from: 1
                    to: 0
                    easing.type: Easing.Linear
                    duration: 315
                }
            }
        }
        delegate: ItemAddress {
            width: listAddr.width
            height: Theme.ph(0.077)
            addr: address
            idx: index
            onClicked: {
                itemClicked(coinType, address, m1, m2)
            }
        }
        footer: Component {
            ItemFooter {
                width: listAddr.width
                height: Theme.ph(0.06) * 3
                onLeftClicked: {
                    var count = modelAddr.count
                    if (count > 1) {
                        modelAddr.remove(count-1)
                        listAddr.positionViewAtEnd()
                        Store.setAddressCount(coinType, count - 1)
                    }
                }
                onRightClicked: {
                    var count = modelAddr.count
                    iconLoading.show()
                    iconLoading.loadingText = ""+count+" / "+(count+1)
                    if (count < Config.maxAddrs) {
                        Store.setAddressCount(coinType, count + 1)
                        loadAddressNextPage()
                        listAddr.positionViewAtEnd()
                    }
                }
            }
        }
    }
}
