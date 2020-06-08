import QtQuick 2.12
import HD.Language 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Math 1.0
import Theme 1.0


Item {
    id: _serviceETH

    property string coinType: "ETH"
    property string status: Lang.txtWait
    property var servList: [agentBlockChair,agentBlockCypher]

    property bool avaliable: true
    property int curServiceIdx: 0
    property string blockTime: "-"
    property int blockHeight: 0
    property string gaslimit: "23000"
    property string gaslimitERC20: "210000"
    property string gasPrice: "26000000000"


    function start() {
        timerCheck.start()

        agentBlockChair.start()
        agentBlockCypher.start()
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
        agentBlockChair.syncBalance(addr)
        return true

        /*
        var idx = chooseService()
        if (idx >= 0) {
            addr = addr.toLowerCase()
            servList[idx].syncBalance(addr)
            return true
        }
        Theme.showToast(coinType + " - syncBalance: no aliable service")
        return false
        */
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
        if (isReplacedNonce(txid, coinType)) {
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

    ETHAgentBlockChair {id:agentBlockChair}
    ETHAgentBlockCypher {id:agentBlockCypher}

    function createTransactionRequest(fromAddr,toAddr,amount,fee,dataset) {
        var req = {}
        try {
            var ds = JSON.parse(dataset)
            req["n"] = ds["n"]
        } catch (e) {
            req["n"] = "0"
        }
        req["f"] = fromAddr
        req["t"] = toAddr
        req["gl"] = gaslimit
        var feewei = HDMath.ethToWei(fee)
        var gp = HDMath.div(feewei, gaslimit)
        req["gp"] = gp
        req["fe"] = fee
        req["v"] = HDMath.ethToWei(amount)
        if (Config.mainnet) {
            req["c"] = "1"
        } else {
            req["c"] = "3"
        }
        return req
    }

    function createTransactionRequestERC20(fromAddr,toAddr,amount,fee,dataset) {
        var req = {}
        try {
            var ds = JSON.parse(dataset)
            req["n"] = ds["n"]
        } catch (e) {
            req["n"] = "0"
        }
        req["f"] = fromAddr
        req["t"] = toAddr
        req["gl"] = gaslimitERC20
        var feewei = HDMath.ethToWei(fee)
        var gp = HDMath.div(feewei, gaslimitERC20)
        req["gp"] = gp
        req["fe"] = fee
        req["v"] = HDMath.ethToWei(amount)
        if (Config.mainnet) {
            req["c"] = "1"
        } else {
            req["c"] = "3"
        }
        return req
    }
}
