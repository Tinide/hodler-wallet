import QtQuick 2.12
import HD.Language 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0


Item {
    id: _serviceEOS

    property string coinType: "EOS"
    property string status: Lang.txtWait
    property var servList: []

    property bool avaliable: false

    function start() {
        timerCheck.start()
    }

    function chooseService() {
        var ci = servList.length - 1
        var rt = 999999
        for (var i = 0; i < servList.length; i++) {
            if (servList[i].responseTime < rt) {
                rt = servList[i].responseTime
                ci = i
            }
        }
        return ci
    }

    function syncBalance(addr) {
        var idx = chooseService()
        if (idx >= 0) {
            //servList[idx].syncBalance(addr)
            return true
        }
        return false
    }

    function sendTransaction(txid,rawtx) {
    }

    function searchTransaction(txreq) {
    }

    Timer {
        id: timerCheck
        repeat: true
        interval: 3000
        onTriggered: {
            status = Lang.txtWait
            for (var i = 0; i < servList.length; i++) {
                if (servList[i].status.startsWith(Lang.txtOK)) {
                    status = Lang.txtOK
                    break
                }
            }
        }
    }

    function createTransactionRequest(fromAddr,toAddr,amount,fee,dataset) {
        return {}
    }
}
