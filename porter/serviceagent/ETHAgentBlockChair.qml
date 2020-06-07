import QtQuick 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import HD.Math 1.0


AgentBase {
    domain: "api.blockchair.com/ethereum"

    property int reqPing: -1
    property string subPing: "/stats"
    property string subAddr: "/dashboards/address/:addr:?limit=30&erc_20=true"
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
        JsonRpc.rpcGet(domain, tls, 0, subAddr.replace(":addr:", addr), domain+"-addr:"+addr)
        reqCount++
    }

    function sendTransaction(txid,rawtx) {
        var rawPost = "data=0x" + rawtx
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
                var feeperbyte = (reply["average_transaction_fee_24h"] / 200) + 25
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
            var dataset = {}
            var pendset = []
            var calls = []
            if (   typeof(infoset) == "undefined"
                || typeof(infoset[addr]) == "undefined") {
                failCount++
                return
            } else {
                dataset = infoset[addr]
                calls = dataset["calls"]
            }
            var pend = "0"
            for (var i = 0; i < calls.length; i++) {
                var pendtx = {}
                if (calls[i]["transferred"] === true) {
                    pendtx["confirmed"] = true
                } else {
                    pendtx["confirmed"] = false
                }
                pendtx["txid"] = calls[i]["transaction_hash"]
                pendtx["from"] = calls[i]["sender"]
                pendtx["to"] = calls[i]["recipient"]
                pendtx["value"] = calls[i]["value"]
                pendset.push(pendtx)
            }
            // combine
            pendset = combineLocalETHPendingSet("ETH", addr, pendset)
            // calc
            for (var j = 0; j < pendset.length; j++) {
                if (pendset[j]["confirmed"] === true) {
                    continue
                }
                if (pendset[j]["from"] === addr) {
                    pend = HDMath.sub(pend, pendset[j]["value"])
                }
                if (pendset[j]["to"] === addr) {
                    pend = HDMath.add(pend, pendset[j]["value"])
                }
            }
            var total = "0"
            if (   typeof(dataset["address"]) == "undefined"
                || dataset["address"] === null
                || typeof(dataset["address"]["balance"]) == "undefined"
                || dataset["address"]["balance"] === null) {
                total = "0"
            } else {
                total = dataset["address"]["balance"]
            }
            var bala = total
            if (HDMath.cmp(pend, 0) < 0) {
                bala = HDMath.add(total, pend)
            } else {
                //total = HDMath.add(total, pend)
            }
            total = HDMath.weiToEth(total)
            bala  = HDMath.weiToEth(bala)
            pend  = HDMath.weiToEth(pend)
            var tc = 0
            var rc = 0
            if (   typeof(dataset["address"]) != "undefined"
                && typeof(dataset["address"]["transaction_count"]) != "undefined"
                && typeof(dataset["address"]["receiving_call_count"]) != "undefined") {
                tc = dataset["address"]["transaction_count"]
                rc = dataset["address"]["receiving_call_count"]
            }
            var jdata = {}
            jdata["n"] = "" + (tc - rc)
            if (typeof(dataset["layer_2"]["erc_20"]) != "undefined") {
                var erc20 = dataset["layer_2"]["erc_20"]
                jdata["erc20"] = erc20
            }
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
                    if (confirms < 0) {
                        confirms = 0
                    }
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
