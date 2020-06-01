import QtQuick 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0


AgentBase {
    domain: "bitcoinblockexplorers.com"

    // insight api
    property int reqPing: -1
    property string subPing: "/api/status?q=getInfo"
    property string subUtxo: "/api/addr/:addr:/utxo"//?noCache=1"
    property string subTx: "/api/tx/:txid:"
    property string subSendTx: "/api/tx/send"

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
        var rawPost = '{"rawtx": "' + rawtx + '"}'
        var jsonObj = {"rawpost": rawPost}
        JsonRpc.rpcCall("", jsonObj, domain+"-btx:"+txid, domain, port, tls, subSendTx)
        reqCount++
    }

    function searchTransaction(txreq) {
        var txid = txreq.replace(/([^:]*):[^:]*/,"$1")
        //var addr = txreq.replace(/[^:]*:([^:]*)/,"$1")
        JsonRpc.rpcGet(domain, tls, 0, subTx.replace(":txid:", txid), domain+"-stx:"+txid)
        reqCount++
    }

    function handlePing(reply) {
        var currentDate = new Date()
        finishPingTime = currentDate.getTime()
        responseTime = finishPingTime - startPingTime
        try {
            status = Lang.txtOK + " - " + (responseTime / 1000.0) + "s"
            //blockHeight = reply["info"]["blocks"]
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
            var utxoset = reply["array"]
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
                jdata[i]["txid"] = utxoset[i]["txid"]
                jdata[i]["vout"] = utxoset[i]["vout"]
                jdata[i]["satoshis"] = utxoset[i]["satoshis"]
                jdata[i]["confirmations"] = utxoset[i]["confirmations"]
            }
            // combine local utxoset
            jdata = combineLocalUtxoSet("BTC", addr, jdata)
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
