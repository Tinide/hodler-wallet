import QtQuick 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Math 1.0
import Theme 1.0


AgentBase {
    domain: "api.blockcypher.com/v1/eth/main"

    property int reqPing: -1
    property string subPing: ""
    property string subAddr: "/addrs/:addr:"
    property string subTx: "/txs/:txid:"
    property string subSendTx: "/txs/push"

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
        var rawPost = '{"tx": "' + rawtx + '"}'
        var jsonObj = {"rawpost": rawPost}
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
            var bh = reply["height"]
            if (blockHeight < bh) {
                blockHeight = bh
                blockTime  = reply["time"]
                var mfee = reply["medium_gas_price"]
                gasPrice = HDMath.mul(mfee, "1.1")
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
            if (typeof(reply["address"]) == "undefined") {
                failCount++
                return
            }
            var bala = reply["balance"]
            var pend = reply["unconfirmed_balance"]
            var total = reply["final_balance"]
            if (pend < 0) {
                var tmp = bala
                bala = total
                total = tmp
            }
            bala  = HDMath.weiToEth(bala)
            pend  = HDMath.weiToEth(pend)
            total = HDMath.weiToEth(total)
            var jdata = {}
            jdata["n"] = "" + (reply["nonce"])
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
        try {
            var txreq = reply["user_data"]
            var txid = txreq.replace(/[^:]*:([^:]*)/,"$1")
            if (typeof(reply["error"]) != "undefined") {
                if (reply["error"].indexOf("already exists") !== -1) {
                    confirms = 0
                }
            }
            if (typeof(reply["confirmations"]) != "undefined") {
                confirms = reply["confirmations"]
            }
            if (confirms >= 0) {
                var result = {"confirmations":confirms}
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
            if (typeof(reply["hash"]) != "undefined") {
                confirms = reply["confirmations"]
                if (confirms < 0) {
                    confirms = 0
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
