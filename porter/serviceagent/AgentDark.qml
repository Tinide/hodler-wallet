import QtQuick 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0


AgentBase {
    domain: "localhost"
    port: 8334
    tls: true
    property bool auth: false
    property string user: ""
    property string pass: ""
    property string ct: "BTC"
    canDelete: true

    property int reqPing: -1

    function start() {
        timerPing.startPingImmediately()
    }

    function ping() {
        var currentDate = new Date()
        startPingTime = currentDate.getTime()
        var jsonObj = {"params": []}
        reqPing = JsonRpc.rpcCall("getblockchaininfo", jsonObj, domain+"-ping",
                                  domain, port, tls, "", user, pass)
        reqCount++
    }

    function syncBalance(addr) {
        var jsonObj = {"params": [addr, 1, 0, 3000, 0]}
        JsonRpc.rpcCall("searchrawtransactions", jsonObj, domain+"-addr:"+addr,
                        domain, port, tls, "", user, pass)
        reqCount++
    }

    function sendTransaction(txid,rawtx) {
        var jsonObj = {"params": [rawtx]}
        JsonRpc.rpcCall("sendrawtransaction", jsonObj, domain+"-btx:"+txid,
                        domain, port, tls, "", user, pass)
        reqCount++
    }

    function searchTransaction(txreq) {
        var txid = txreq.replace(/([^:]*):[^:]*/,"$1")
        var addr = txreq.replace(/[^:]*:([^:]*)/,"$1")
        var jsonObj = {"params": [addr, 1, 0, 3000, 0]}
        JsonRpc.rpcCall("searchrawtransactions", jsonObj, domain+"-stx:"+addr+":"+txid,
                        domain, port, tls, "", user, pass)
        reqCount++
    }

    function handlePing(reply) {
        var currentDate = new Date()
        finishPingTime = currentDate.getTime()
        responseTime = finishPingTime - startPingTime
        try {
            status = Lang.txtOK + " - " + (responseTime / 1000.0) + "s"
            var bh = reply["result"]["blocks"]
            if (blockHeight < bh) {
                blockHeight = bh
                var tm  = reply["result"]["mediantime"]
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
            var addr = reply["user_data"]
            addr = addr.replace(/[^:]*:([^:]*)/,"$1")
            var utxoset = reply["result"]
            if (reply["error"] !== null) {
                failCount++
                return
            }
            if (utxoset === null) {
                utxoset = []
            }
            var bala = 0
            var pend = 0
            var total = 0
            var jdataall = []
            var jdata = []
            var txid, i, j
            // build utxoset
            for (i = 0; i < utxoset.length; i++) {
                txid = utxoset[i]["txid"]
                var vout = utxoset[i]["vout"]
                for (j = 0; j < vout.length; j++) {
                    if (vout[j]["scriptPubKey"]["addresses"][0] !== addr) {
                        continue
                    }
                    var utxo = {}
                    utxo["txid"] = txid
                    utxo["vout"] = vout[j]["n"]
                    utxo["satoshis"] = Config.coinsAmountValue("" + vout[j]["value"], "BTC")
                    utxo["confirmations"] = utxoset[i]["confirmations"]
                    if (typeof(utxo["confirmations"]) == "undefined") {
                        utxo["confirmations"] = 0
                    }
                    jdataall.push(utxo)
                }
            }
            // erase spent
            for (i = 0; i < jdataall.length; i++) {
                txid = jdataall[i]["txid"]
                var n = jdataall[i]["vout"]
                var bfind = false
                for (var u = 0; u < utxoset.length; u++) {
                    var vin = utxoset[u]["vin"]
                    for (j = 0; j < vin.length; j++) {
                        if (vin[j]["txid"] === txid && vin[j]["vout"] === n) {
                            bfind = true
                            break
                        }
                    }
                    if (bfind) {break}
                }
                if (bfind) {
                    continue
                }
                jdata.push(jdataall[i])
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
            var bstr = Config.coinsAmountString(bala, "BTC")
            var pstr = Config.coinsAmountString(pend, "BTC")
            var tstr = Config.coinsAmountString(total, "BTC")
            Config.balanceResult(addr, bstr, pstr, tstr, jstr)
            //Config.debugOut(domain+" - BTC: "+addr+", b:"+bstr+", p:"+pstr+", t:"+tstr)//+", j:"+jstr)
        } catch (e) {
            Config.debugOut(domain + "-utxo: " + e)
        }
    }

    function handleSendTransaction(reply) {
        var confirms = -1
        try {
            var txreq = reply["user_data"]
            var txid = txreq.replace(/[^:]*:([^:]*)/,"$1")
            if (reply["error"] !== null) {
                var msg = reply["error"]["message"]
                if (msg.indexOf("insufficient priority") !== -1) {
                    confirms = -2
                    var result = {"confirmations":confirms}
                    Config.transactionResult(txid, JSON.stringify(result))
                }
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
            var txid = txreq.replace(/[^:]*:[^:]*:([^:]*)/,"$1")
            var utxoset = reply["result"]
            if (typeof(utxoset) != "undefined") {
                for (var i = 0; i < utxoset.length; i++) {
                    if (utxoset[i]["txid"] === txid) {
                        confirms = utxoset[i]["confirmations"]
//                        if (typeof(confirms) == "undefined") {
//                            confirms = -1
//                        }
                        var result = {"confirmations":confirms}
                        Config.transactionResult(txid, JSON.stringify(result))
                        break
                    }
                }
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
