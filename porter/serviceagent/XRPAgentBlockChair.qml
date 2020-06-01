import QtQuick 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import HD.Math 1.0


AgentBase {
    domain: "api.blockchair.com/ripple"
    property string txdomain: "api.xrpscan.com"
    property string sdomain: "s2.ripple.com"

    property int reqPing: -1
    property string subPing: "/stats"
    property string subAddr: "/raw/account/:addr:" //?transactions=true"
    property string subTx: "/api/v1/tx/:txid:"
    property string subSendTx: "/"

    function start() {
        timerPing.startPingImmediately()
    }

    function ping() {
        var currentDate = new Date()
        startPingTime = currentDate.getTime()
        reqPing = JsonRpc.rpcGet(domain, tls, 0, subPing)
        reqCount++
        //console.info("ping start")
    }

    function syncBalance(addr) {
        JsonRpc.rpcGet(domain, tls, 0, subAddr.replace(":addr:", addr), domain+"-addr:"+addr)
        reqCount++
    }

    function sendTransaction(txid,rawtx) {
        var rawPost = '{"method":"submit","params":[{"tx_blob":"' + rawtx + '"}]}'
        var jsonObj = {"rawpost": rawPost, "Content-Type": "application/json"}
        JsonRpc.rpcCall("", jsonObj, sdomain+"-btx:"+txid, sdomain, 51234, tls, subSendTx)
        reqCount++
    }

    function searchTransaction(txreq) {
        var txid = txreq.replace(/([^:]*):[^:]*/,"$1")
        //var addr = txreq.replace(/[^:]*:([^:]*)/,"$1")
        var subtx = subTx.replace(":txid:", txid)
        JsonRpc.rpcGet(txdomain, tls, 0, subtx, txdomain+"-stx:"+txid)
        reqCount++
    }

    function handlePing(reply) {
        var currentDate = new Date()
        finishPingTime = currentDate.getTime()
        responseTime = finishPingTime - startPingTime
        try {
            status = Lang.txtOK + " - " + (responseTime / 1000.0) + "s"
            reply = reply["data"]
            var bh = reply["best_ledger_height"]
            if (blockHeight < bh) {
                blockHeight = bh
                blockTime  = reply["best_ledger_time"]
                var totalFee = reply["average_transaction_fee_24h"]
                var totalTxs = reply["transactions_24h"]
                bestFee = (totalFee / totalTxs).toFixed(6)
            }
        } catch (e) {
            status = Lang.txtRetry
            responseTime = 999999
            failCount++
            Config.debugOut(domain + " ping error")
        }
        //Config.debugOut(domain + " - time: " + blockTime + ", " + "txs: " + ", " + "fee: " + feeperbyte + ", "+ "blockheight: " + blockHeight + ", " + status)
        //console.info("ping end - " + responseTime)
        if (responseTime < Config.pingInterval) {
            timerPing.startPing()
        } else {
            timerPing.startPingImmediately()
        }
    }

    function handleAddress(reply) {
        try {
            var addr = reply["user_data"]
            addr = addr.replace(/[^:]*:([^:]*)/,"$1")
            var infoset = reply["data"]
            if (typeof(infoset) == "undefined") {
                Theme.showToast(Lang.msgBadNetworkResponse)
                failCount++
                return
            }
            // calc local pending
            var pend = "0"

            if (infoset === null) {
                //Config.balanceResult(addr, "0", "0", "0", "{}")
                return
            }

            // calc balance
            var adata = infoset[addr]["account"]["account_data"]
            var bala = adata["Balance"]
            bala = HDMath.dropToXrp(bala)
            var total = bala

            var jdata = {}
            jdata["n"]  = adata["Sequence"]
            jdata["ln"] = infoset[addr]["account"]["ledger_current_index"] + 100

            var jstr = JSON.stringify(jdata, "", "  ")
            Config.balanceResult(addr, bala, pend, total, jstr)
            //Config.debugOut(domain+" - LTC: "+addr+", b:"+bstr+", p:"+pstr+", t:"+tstr)//+", j:"+jstr)
        } catch (e) {
            if (Config.debugMode) {
                Theme.showToast(e)
            }
        }
    }

    function handleSendTransaction(reply) {
        try {
            var txreq = reply["user_data"]
            var txid = txreq.replace(/[^:]*:([^:]*)/,"$1")
            if (reply["result"]["accepted"] === true) {
                var result = {"confirmations":0}
                Config.transactionResult(txid, JSON.stringify(result))
            }
        } catch (e) {
            failCount++
            Config.debugOut(domain + "-stx: " + e)
        }
    }

    function handleTransactions(reply) {
        try {
            var txreq = reply["user_data"]
            var txid = txreq.replace(/[^:]*:([^:]*)/,"$1")
            if (reply["Amount"]["currency"] === "XRP") {
                var result = {"confirmations":100}
                Config.transactionResult(txid, JSON.stringify(result))
            }
        } catch (e) {
            failCount++
            Config.debugOut(domain + "-stx: " + e)
        }
    }

    Connections {
        target: JsonRpc
        onRpcReply: {
            if (id == reqPing) {
                handlePing(reply)
                return
            }
            if (   reply["user_data"].startsWith(domain) === false
                && reply["user_data"].startsWith(txdomain) === false
                && reply["user_data"].startsWith(sdomain) === false) {
                return
            }
            if (reply["user_data"].startsWith(domain+"-addr:")) {
                handleAddress(reply)
                return
            }
            if (reply["user_data"].startsWith(sdomain+"-btx:")) {
                handleSendTransaction(reply)
                return
            }
            if (reply["user_data"].startsWith(txdomain+"-stx:")) {
                handleTransactions(reply)
                return
            }
        }
    }

    Timer {
        id: timerPing
        repeat: false
        interval: Config.pingInterval
        onTriggered: { ping() }
        function startPing() {
            timerPing.interval = Config.pingInterval + ((Math.floor(Math.random()*(10))+1)*1000)
            timerPing.start()
        }
        function startPingImmediately() {
            timerPing.interval = 2000
            timerPing.start()
        }
    }
}
