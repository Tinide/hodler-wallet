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
    id: _listHistory


    signal itemClicked(string jsonData)
    signal itemDelete(int deltxid)

    function clearMainHistory() {
        modelHistory.clear()
    }

    function loadMainHistory() {
        clearMainHistory()

        var str = Store.querySignHistory()
        var his = JSON.parse(str)
        var count = his.length
        for (var i = 0; i < count; i++) {
            var item = his[i]
            var jsonD = JSON.stringify(item)
            var coinT = item["coinType"]
            var dateT = item["datetime"]
            var fromAddr = item["fromAddr"]
            var toAddr = item["toAddr"]
            var amount = item["amount"]
            var fee = item["fee"]
            var raw = item["raw"]
            var recid = item["recid"]
            var summ = Lang.txtSendTo + " " + toAddr + "  " + amount; //Config.coinsAmountString(amount, coinT)
            modelHistory.insert(0, {ct:coinT,dt:dateT,from:fromAddr,to:toAddr,am:amount,
                                    fe:fee,rtx:raw,ol:summ,jd:jsonD,rid:recid})
        }
    }

    function deleteItem() {
        modelHistory.remove(listHistory.delCandidate)
    }

    ListModel {
        id: modelHistory
    }

    ListView {
        id: listHistory
        clip: true
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        ScrollBar.vertical: ScrollBar {}
        property int delCandidate: -1
        model: modelHistory
        delegate: ItemMainHistory {
            width: listHistory.width
            height: Theme.ph(0.077)
            coinType: ct
            dateTime: dt
            fromAddr: from
            toAddr: to
            amount: am
            fee: fe
            rawTx: rtx
            outline: ol
            jsonData: jd
            onClicked: {
                itemClicked(jsonData)
            }
            onDeleted: {
                listHistory.delCandidate = index
                itemDelete(rid)
            }
        }
        footer: Item {
            width: listHistory.width
            height: bottomBar.height * 0.36
        }
    }
}
