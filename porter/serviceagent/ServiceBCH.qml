import QtQuick 2.12
import HD.Language 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0


Item {
    id: _serviceBCH

    property string coinType: "BCH"
    property string status: Lang.txtWait
    property var servList: [agentBitcoinCom,agentBTCCom,agentBlockChair]

    property bool avaliable: false
    property int curServiceIdx: 0
    property string blockTime: "-"
    property int blockHeight: 0
    property double feeperbyte: 80
    property var darkcom: null


    function start() {
        darkcom = Qt.createComponent("AgentDark.qml")
        loadDarkService()
        timerCheck.start()

        agentBitcoinCom.start()
        agentBTCCom.start()
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
        if (servList[idx] === agentBTCCom) {
            idx = chooseService()
        }
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
        var com = darkcom.createObject(_serviceBCH,{domain:dm,port:po,tls:t,auth:a,user:u,pass:p,ct:"BCH"})
        if (com === null) {
            Theme.showToast("Error creating dark-api object")
            return
        }
        com.start()
        servList.push(com)
        avaliable = true
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

    BCHAgentBitcoinCom {id:agentBitcoinCom}
    BCHAgentBTCCom {id:agentBTCCom}
    BCHAgentBlockChair {id:agentBlockChair}

    function createTransactionRequest(fromAddr,toAddr,amount,fee,dataset) {
        var req = {}
        var utxoAmount = 0
        var iamounts = []
        try {
            var inputs = []
            var uset = JSON.parse(dataset)
            for (var i = 0; i < uset.length; i++) {
                if (uset[i]["confirmations"] <= 0) {
                    continue
                }
                var u = {}
                u["txid"] = uset[i]["txid"]
                u["vout"] = uset[i]["vout"]
                u["satoshis"] = uset[i]["satoshis"]
                inputs.push(u)
                iamounts.push(uset[i]["satoshis"])
                utxoAmount += uset[i]["satoshis"]
                if (amount + fee <= utxoAmount) {
                    break
                }
            }
            req["inputs"] = inputs
            req["inputs_amounts"] = iamounts
        } catch (e) {
            Theme.showToast(e)
            return []
        }
        var output = {}
        output[toAddr] = amount / Config.satmul
        if (amount + fee < utxoAmount) {
            output[fromAddr] = (utxoAmount - amount - fee) / Config.satmul
        }
        req["amounts"] = output
        req["utxoamount"] = utxoAmount
        req["mainnet"] = Config.mainnet
        return [req]
    }

    function createReplacedTransactionRequest(fromAddr,toAddr,amount,fee,utxoAmount,txins) {
        var req = {}
        req["inputs"] = JSON.parse(txins)
        req["sequence"] = req["inputs"][0]["sequence"] + 1

        var output = {}
        output[toAddr] = amount / Config.satmul
        if (amount + fee < utxoAmount) {
            output[fromAddr] = (utxoAmount - amount - fee) / Config.satmul
        }
        req["amounts"] = output
        req["utxoamount"] = utxoAmount
        req["mainnet"] = Config.mainnet
        return [req]
    }
}
