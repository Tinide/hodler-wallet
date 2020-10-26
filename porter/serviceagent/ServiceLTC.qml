import QtQuick 2.12
import HD.Language 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0


Item {
    id: _serviceLTC

    property string coinType: "LTC"
    property string status: Lang.txtWait
    property var servList: [agentLitecore,agentBlockCypher,agentBlockChair]

    property bool avaliable: true
    property int curServiceIdx: 0
    property string blockTime: "-"
    property int blockHeight: 0
    property double feeperbyte: 450
    property var darkcom: null

    function start() {
        darkcom = Qt.createComponent("AgentDark.qml")
        loadDarkService()
        timerCheck.start()

        agentLitecore.start()
        agentBlockCypher.start()
        //agentCoinExplorer.start()
        agentBlockChair.start()
    }

    function loadDarkService() {
        var strList = Store.queryService(coinType)
        try {
            var slist = JSON.parse(strList)
            for (var i = 0; i < slist.length; i++) {
                var item = slist[i]
                addDarkService(item["domain"], item["port"], item["tls"],
                               item["auth"], item["user"], item["pass"])
            }
        } catch (e) {
            Theme.showToast(coinType + "-load service: " + e)
        }
    }

    function chooseService() {
        if (servList.length == 0) {
            return -1
        }
        for (var i = curServiceIdx; i < servList.length; i++) {
            if (servList[i].responseTime < 10000) {
                curServiceIdx = (i + 1) % servList.length
                return i
            }
        }
        for (i = 0; i < curServiceIdx; i++) {
            if (servList[i].responseTime < 10000) {
                curServiceIdx = (i + 1) % servList.length
                return i
            }
        }
        return Math.floor(Math.random()*(servList.length))
    }

    function syncBalance(addr) {
        var idx = chooseService()
        if (idx >= 0) {
            servList[idx].syncBalance(addr)
            return true
        }
        Theme.showToast(coinType + " - syncBalance: no aliable service")
        return false
    }

    function sendTransaction(txid,rawtx) {
        var idx = chooseService()
        if (idx >= 0) {
            servList[idx].sendTransaction(txid,rawtx)
            return true
        }
        Theme.showToast(coinType + " - sendTransaction: no aliable service")
        return false
    }

    function searchTransaction(txreq) {
        var txid = txreq.replace(/([^:]*):[^:]*/,"$1")
        if (isReplacedTransaction(txid, coinType)) {
            var result = {"confirmations":-3}
            Config.transactionResult(txid, JSON.stringify(result))
            return
        }

        var idx = chooseService()
        if (idx >= 0) {
            servList[idx].searchTransaction(txreq)
            return true
        }
        Theme.showToast(coinType + " - searchTransaction no aliable service")
        return false
    }

    function addDarkService(dm,po,t,a,u,p) {
        if (darkcom.status !== Component.Ready) {
            Theme.showToast("AgentDark.qml component failed")
            return
        }
        var com = darkcom.createObject(_serviceLTC,{domain:dm,port:po,tls:t,auth:a,user:u,pass:p,ct:"LTC"})
        if (com === null) {
            Theme.showToast("Error creating dark-api object")
            return
        }
        com.start()
        servList.push(com)
    }

    Connections {
        target: Store
        onServiceDeleted: {
            for (var i = 0; i < servList.length; i++) {
                if (servList[i].domain === domain && servList[i].port === port) {
                    servList.splice(i, 1)
                    break
                }
            }
        }
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

    LTCAgentLitecore {id:agentLitecore}
    LTCAgentBlockCypher {id:agentBlockCypher}
    //LTCAgentCoinExplorer {id:agentCoinExplorer}
    LTCAgentBlockChair {id:agentBlockChair}
}
