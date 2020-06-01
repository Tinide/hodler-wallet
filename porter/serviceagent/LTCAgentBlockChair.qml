import QtQuick 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0


AgentBase {
    domain: "api.blockchair.com/litecoin"

    property int reqPing: -1
    property string subPing: "/stats"
    property string subUtxo: "/dashboards/address/:addr:?limit=0,1000"
    property string subTx: "/dashboards/transaction/:txid:"
    property string subSendTx: "/push/transaction"

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
        JsonRpc.rpcGet(domain, tls, 0, subUtxo.replace(":addr:", addr), domain+"-addr:"+addr)
        reqCount++
    }

    function sendTransaction(txid,rawtx) {
        var rawPost = "data=" + rawtx
        var jsonObj = {"rawpost": rawPost,
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"}
        JsonRpc.rpcCall("", jsonObj, domain+"-btx:"+txid, domain, port, tls, subSendTx)
        reqCount++
    }

    function searchTransaction(txreq) {
        var txid = txreq.replace(/([^:]*):[^:]*/,"$1")
        //var addr = txreq.replace(/[^:]*:([^:]*)/,"$1")
        var subtx = subTx.replace(":txid:", txid)
        JsonRpc.rpcGet(domain, tls, 0, subtx, domain+"-stx:"+txid)
        reqCount++
    }

    function handlePing(reply) {
        var currentDate = new Date()
        finishPingTime = currentDate.getTime()
        responseTime = finishPingTime - startPingTime
        try {
            status = Lang.txtOK + " - " + (responseTime / 1000.0) + "s"
            reply = reply["data"]
            var bh = reply["best_block_height"]
            if (blockHeight < bh) {
                blockHeight = bh
                blockTime  = reply["best_block_time"]
                feeperbyte = (reply["average_transaction_fee_24h"] / 200) + 25
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

    function handleUtxo(reply) {
        try {
//            if (reply["success"] === false) {
//                throw domain + " get LTC utxo failed"
//            }
            var addr = reply["user_data"]
            addr = addr.replace(/[^:]*:([^:]*)/,"$1")
            var utxoset = reply["data"]
            if (   typeof(utxoset) == "undefined"
                || typeof(utxoset[addr]) == "undefined"
                || typeof(utxoset[addr]["utxo"]) == "undefined") {
                failCount++
                utxoset = []
            } else {
                utxoset = utxoset[addr]["utxo"]
            }

            var bala = 0
            var pend = 0
            var total = 0
            var jdata = []
            for (var i = 0; i < utxoset.length; i++) {
                jdata[i] = {}
                jdata[i]["txid"] = utxoset[i]["transaction_hash"]
                jdata[i]["vout"] = utxoset[i]["index"]
                jdata[i]["satoshis"] = utxoset[i]["value"]
                if (utxoset[i]["block_id"] > 0) {
                    jdata[i]["confirmations"] = blockHeight - utxoset[i]["block_id"] + 1
                    if (jdata[i]["confirmations"] < 0) {
                        jdata[i]["confirmations"] = 1
                    }
                } else {
                    jdata[i]["confirmations"] = 0
                }
            }
            // combine local utxoset
            jdata = combineLocalUtxoSet("LTC", addr, jdata)
            // calc amount
            for (i = 0; i < jdata.length; i++) {
                var tx = jdata[i]
                var vi = tx["satoshis"]
                if (tx["confirmations"] === 0) {
                    pend += vi
                } else {
                    bala += vi
                }
                total += vi
            }
            var jstr = JSON.stringify(jdata, "", "  ")
            var bstr = "" + (bala / 100000000)
            var pstr = "" + (pend / 100000000)
            var tstr = "" + (total / 100000000)
            Config.balanceResult(addr, bstr, pstr, tstr, jstr)
            //Config.debugOut(domain+" - LTC: "+addr+", b:"+bstr+", p:"+pstr+", t:"+tstr)//+", j:"+jstr)
        } catch (e) {
            if (Config.debugMode) {
                Theme.showToast(e)
            }
        }
    }

    function handleSendTransaction(reply) {
        var confirms = -1
        var result = {"confirmations":confirms}
        try {
            var txreq = reply["user_data"]
            var txid = txreq.replace(/[^:]*:([^:]*)/,"$1")
            if (   typeof(reply["context"]) != "undefined"
                && reply["data"] === null) {
                result = {"confirmations":-2}
                //Config.transactionResult(txid, JSON.stringify(result))
                Config.debugOut(reply["context"]["error"])
                return
            }
            if (reply["data"]["transaction_hash"] === txid) {
                result = {"confirmations":0}
                Config.transactionResult(txid, JSON.stringify(result))
            }
        } catch (e) {
            failCount++
            Config.debugOut(domain + "-stx: " + e)
        }
    }

    function handleTransactions(reply) {
        var confirms = -1
        try {
            var txreq = reply["user_data"]
            var txid = txreq.replace(/[^:]*:([^:]*)/,"$1")
            if (   typeof(reply["data"]) != "undefined"
                && typeof(reply["data"][txid]) != "undefined") {
                reply = reply["data"][txid]["transaction"]
                confirms = 0
                if (   typeof(reply["block_id"]) != "undefined"
                    && reply["block_id"] > 0) {
                    confirms = blockHeight - reply["block_id"] + 1
                }
                var result = {"confirmations":confirms}
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
                handleUtxo(reply)
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
