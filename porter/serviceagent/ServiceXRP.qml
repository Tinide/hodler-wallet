﻿import QtQuick 2.12
import HD.Language 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Math 1.0
import Theme 1.0


Item {
    id: _serviceXRP

    property string coinType: "XRP"
    property string status: Lang.txtWait
    property var servList: [agentBlockChair,agentRippleCom]

    property bool avaliable: true
    property int curServiceIdx: 0
    property string blockTime: "-"
    property int blockHeight: 0
    property double bestFee: 0

    function start() {
        timerCheck.start()

        agentBlockChair.start()
        agentRippleCom.start()
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
        var idx = chooseService()
        if (idx >= 0) {
            servList[idx].syncBalance(addr)
            return true
        }
        Theme.showToast(coinType + " - syncBalance: no aliable service")
        return false
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

    XRPAgentBlockChair {id:agentBlockChair}
    XRPAgentRippleCom {id:agentRippleCom}
//    XRPAgentRippleCom {
//        id: agentRippleCom2
//        domain: "s2.ripple.com"
//        port: 51234
//    }

    function createTransactionRequest(fromAddr,toAddr,amount,fee,dataset) {
        var req = {}
        try {
            req = JSON.parse(dataset)
        } catch (e) {
            req = {}
            req["n"] = "0"
            req["ln"] = "0"
        }
        req["f"] = fromAddr
        req["t"] = toAddr
        req["fe"] = fee
        req["v"] = amount //HDMath.xrpToDrop(amount)
        return req
    }
}