import QtQuick 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Math 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0


AgentBase {
    domain: "bch-chain.api.btc.com"

    property int reqPing: -1
    property string subPing: "/v3/block/latest"
    property string subUtxo: "/v3/address/:addr:/unspent"
    property string subTx: "/v3/tx/:txid:"
    property string subSendTx: "/api/v1/tools/tx-publish"


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
        var legacyaddr = HDMath.toCashLegacy(addr)
        JsonRpc.rpcGet(domain, tls, 0, subUtxo.replace(":addr:", legacyaddr), domain+"-addr:"+addr)
        reqCount++
    }

    function sendTransaction(txid,rawtx) {
        // server internal error
        var rawPost = "rawhex=" + rawtx
        var jsonObj = {"rawpost": rawPost,
            "Content-Type": "application/x-www-form-urlencoded",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"}
        JsonRpc.rpcCall("", jsonObj, domain+"-btx:"+txid, "btc.com", port, tls, subSendTx)
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
            var bh = reply["height"]
            if (blockHeight < bh) {
                blockHeight = bh
                var size = reply["size"]
                var fee  = reply["reward_fees"]
                feeperbyte = (fee / size).toFixed(0) + 30
                var tm  = reply["timestamp"]
                var bt = new Date(tm * 1000)
                blockTime = Qt.formatDateTime(bt, "yyyy-MM-dd hh:mm:ss")
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
//                throw domain + " get BTC utxo failed"
//            }
            var addr = reply["user_data"]
            addr = addr.replace(/[^:]*:([^:]*)/,"$1")
            reply = reply["data"]
            var utxoset = reply["list"]
            if (typeof(utxoset) == "undefined") {
                utxoset = []
                failCount++
            }
            var bala = 0
            var pend = 0
            var total = 0
            var jdata = []
            for (var i = 0; i < utxoset.length; i++) {
                jdata[i] = {}
                jdata[i]["txid"] = utxoset[i]["tx_hash"]
                jdata[i]["vout"] = utxoset[i]["tx_output_n"]
                jdata[i]["satoshis"] = utxoset[i]["value"]
                jdata[i]["confirmations"] = utxoset[i]["confirmations"]
            }
            // combine local utxoset
            jdata = combineLocalUtxoSet("BCH", addr, jdata)
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
            //addr = Tools.toCashAddress(addr)
            Config.balanceResult(addr, bstr, pstr, tstr, jstr)
            //Config.debugOut(domain+" - BTC: "+addr+", b:"+bstr+", p:"+pstr+", t:"+tstr)//+", j:"+jstr)
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
            reply = reply["data"]
            if (typeof(reply["confirmations"]) != "undefined") {
                confirms = reply["confirmations"]
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
