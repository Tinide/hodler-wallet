import QtQuick 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import HD.Math 1.0


AgentBase {
    domain: "s1.ripple.com"
    port: 51234

    property int reqPing: -1


    function start() {
        timerPing.startPingImmediately()
    }

    function ping() {
        var currentDate = new Date()
        startPingTime = currentDate.getTime()
        var jsonObj = {"params": [{}]}
        reqPing = JsonRpc.rpcCall("fee", jsonObj, domain+"-ping", domain, port, tls, "/")
        reqCount++
    }

    function syncBalance(addr) {
        var currentDate = new Date()
        startPingTime = currentDate.getTime()
        var jsonObj = {"params": [{"account":addr,
                                   "strict":true,
                                   "ledger_index":"current",
                                   "queue":true
                                  }]}
        JsonRpc.rpcCall("account_info", jsonObj, domain+"-addr:"+addr, domain, port, tls, "/")
        reqCount++
    }

    function sendTransaction(txid,rawtx) {
        var jsonObj = {"params": [{"tx_blob":rawtx}]}
        JsonRpc.rpcCall("submit", jsonObj, domain+"-btx:"+txid, domain, port, tls, "/")
        reqCount++
    }

    function searchTransaction(txreq) {
        var txid = txreq.replace(/([^:]*):[^:]*/,"$1")
        //var addr = txreq.replace(/[^:]*:([^:]*)/,"$1")
        var jsonObj = {"params": [{"transaction":txid,
                                   "binary": false
                                  }]}
        JsonRpc.rpcCall("tx", jsonObj, domain+"-stx:"+txid, domain, port, tls, "/")
        reqCount++
    }

    function handlePing(reply) {
        var currentDate = new Date()
        finishPingTime = currentDate.getTime()
        responseTime = finishPingTime - startPingTime
        try {
            status = Lang.txtOK + " - " + (responseTime / 1000.0) + "s"
            reply = reply["result"]
            var bh = reply["ledger_current_index"]
            if (blockHeight < bh) {
                blockHeight = bh
                var mfee = reply["drops"]["median_fee"]
                bestFee = (mfee / 1000000).toFixed(6)
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
            var infoset = reply["result"]
            if (   typeof(infoset) == "undefined"
                || typeof(infoset["account_data"]) == "undefined") {
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
            var adata = infoset["account_data"]
            var bala = adata["Balance"]
            bala = HDMath.dropToXrp(bala)
            var total = bala

            var jdata = {}
            jdata["n"]  = adata["Sequence"]
            jdata["ln"] = infoset["ledger_current_index"] + 100

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
            if (reply["result"]["validated"] === true) {
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
            if (reply["user_data"].startsWith(domain) === false) {
                return
            }
            if (reply["user_data"].startsWith(domain+"-addr:")) {
                handleAddress(reply)
                return
            }
            if (reply["user_data"].startsWith(domain+"-btx:")) {
                handleSendTransaction(reply)
                return
            }
            if (reply["user_data"].startsWith(domain+"-stx:")) {
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
