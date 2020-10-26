import QtQuick 2.12
import QtWebSockets 1.0
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Math 1.0
import Theme 1.0

// https://discovery-31.polkascan.io/network
// https://explorer-31.polkascan.io/polkadot/api/v1/networkstats/latest
// https://explorer-31.polkascan.io/polkadot/api/v1/account/12TbvYR6Jh65irwpUUGdLhdPCHP31dNZtrsT46iZR2Bqubob
// https://explorer-31.polkascan.io/polkadot/api/v1/extrinsic/0xa1d11fa8b90a2a50c82e66498b1ae92d026074dcae92c81e0e8f649dcd266731?include=events

AgentBase {
    domain: "explorer-31.polkascan.io"

    property int reqPing: -1
    property int reqSend: 0
    property string subPing: "/polkadot/api/v1/networkstats/latest"
    property string subAddr: "/polkadot/api/v1/account/:addr:"
    property string subTx:   "/polkadot/api/v1/extrinsic/:txid:"


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
        _dotSocket.sendRawTx(txid, rawtx)
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
            var bh = reply["attributes"]["best_block"]
            if (blockHeight < bh) {
                blockHeight = bh
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
            if (   typeof(infoset) == "undefined"
                || typeof(infoset["attributes"]) == "undefined") {
                failCount++
                return
            } else {
                dataset = infoset["attributes"]
            }
            if (dataset["balance_total"] === null) {
                Config.balanceResult(addr, "0", "0", "0", "{}")
                return
            }

            var total = "" + dataset["balance_total"]
            var bala  = "" + dataset["balance_free"]
            var pend  = "" + dataset["balance_reserved"]

            total = HDMath.fdiv(total, "10000000000")
            bala  = HDMath.fdiv(bala, "10000000000")
            pend  = HDMath.fdiv(pend, "10000000000")
            var jdata = {}
            jdata["n"] = dataset["nonce"]
            var jstr = JSON.stringify(jdata, "", "  ")
            Config.balanceResult(addr, bala, pend, total, jstr)
            //Config.debugOut(domain+" - DOT: "+addr+", b:"+bstr+", p:"+pstr+", t:"+tstr)//+", j:"+jstr)
        } catch (e) {
            if (Config.debugMode) {
                Theme.showToast(e)
            }
        }
    }

    function handleTransactions(reply) {
        var confirms = -1
        try {
            var txreq = reply["user_data"]
            var txid = txreq.replace(/[^:]*:([^:]*)/,"$1")
            if (   typeof(reply["data"]) != "undefined"
                && typeof(reply["data"]["attributes"]) != "undefined"
                && typeof(reply["data"]["attributes"]["success"]) != "undefined") {
                var rc = reply["data"]["attributes"]["success"]
                if (rc === 1) {
                    confirms = 7
                } else {
                    confirms = -2
                }
                var result = {"confirmations":confirms}
                Config.transactionResult(txid, JSON.stringify(result))
            }
            // {"error": "service unavailable"}
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

    WebSocket {
        id: _dotSocket
        url: "wss://rpc.polkadot.io"

        property string stxid: ""
        property string srawtx: ""

        onTextMessageReceived: {
            console.info("wss-" + message)
            var reply
            var result
            try {
                reply = JSON.parse(message)
            } catch (e) {
                console.info("bad wss response: " + message)
                _dotSocket.active = false
                return
            }
            if (reqSend !== reply["id"]) {
                _dotSocket.active = false
                return
            }
            if (typeof(reply["error"]) != "undefined") {
                if (message.indexOf("Transaction is temporarily banned") != -1) {
                    // tx exists
                    _dotSocket.active = false
                    return
                }
                result = {"confirmations":-2}
                Config.transactionResult(stxid, JSON.stringify(result))
                console.info(message)
                _dotSocket.active = false
                return
            }
            if (typeof(reply["result"]) != "undefined"
                    && reply["result"] === stxid) {
                result = {"confirmations":0}
                Config.transactionResult(stxid, JSON.stringify(result))
                _dotSocket.active = false
                return
            }
            _dotSocket.active = false

// ok
// {"jsonrpc":"2.0","result":"0x877e6fea8fdf2ef39020c0112c2a020296247443639a36559375026b1c144363","id":1}
// err1
// {"jsonrpc":"2.0","error":{"code":1010,"message":"Invalid Transaction","data":"Inability to pay some fees (e.g. account balance too low)"},"id":1}
        }
        onStatusChanged: {
            if (_dotSocket.status == WebSocket.Error) {
                console.log("Error: " + _dotSocket.errorString)
            } else if (_dotSocket.status == WebSocket.Open) {
                var txJson = '{
"id": :reqSend:,
"jsonrpc": "2.0",
"method": "author_submitExtrinsic",
"params": [":rawtx:"]
}
'
                reqSend++
                txJson = txJson.replace(":reqSend:", "" + reqSend)
                txJson = txJson.replace(":rawtx:", srawtx)
                _dotSocket.sendTextMessage(txJson)

            } else if (_dotSocket.status == WebSocket.Closed) {
                console.log("Secure socket closed")
            }
        }
        active: false

        function sendRawTx(txid, rawtx) {
            stxid = txid
            srawtx = rawtx
            _dotSocket.active = true
        }
    }
}
