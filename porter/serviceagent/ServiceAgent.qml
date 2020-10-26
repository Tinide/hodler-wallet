import QtQuick 2.12
import HD.Language 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Math 1.0
import Theme 1.0


Item {
    id: _serviceAgent
    width: 0
    height: 0

    property var servList: [servbtc,servltc,serveth,servbch,servbsv,servxrp,servdot]

    Component.onCompleted: {
        _serviceAgent.start()
    }

    Connections {
        target: Store
        onServiceAdded: {
            switch (coinType) {
            case "BTC":
                servbtc.addDarkService(domain, port, tls, auth, user, pass)
                break
            case "LTC":
                servltc.addDarkService(domain, port, tls, auth, user, pass)
                break
            case "BCH":
                servbch.addDarkService(domain, port, tls, auth, user, pass)
                break
            case "BSV":
                servbsv.addDarkService(domain, port, tls, auth, user, pass)
                break
            }
        }
    }

    function start() {
        servbtc.start()
        servltc.start()
        serveth.start()
        servbch.start()
        servbsv.start()
        servxrp.start()
        servdot.start()
    }

    function serviceAvalible(coinType) {
        switch (coinType) {
        case "BTC":
            return servbtc.avaliable
        case "LTC":
            return servltc.avaliable
        case "BCH":
            return servbch.avaliable
        case "BSV":
            return servbsv.avaliable
        case "ETH":
            return serveth.avaliable
        case "XRP":
            return servxrp.avaliable
//        case "EOS":
//            return serveos.avaliable
        case "DOT":
            return servdot.avaliable
        }
        return {}
    }

    function createTransactionRequest(coinType,fromAddr,toAddr,amount,fee,dataset) {
        switch (coinType) {
        case "BTC":
        case "LTC":
            return servbtc.createTransactionRequest(fromAddr,toAddr,amount,fee,dataset)
        case "BCH":
        case "BSV":
            return servbch.createTransactionRequest(fromAddr,toAddr,amount,fee,dataset)
        case "ETH":
            return serveth.createTransactionRequest(fromAddr,toAddr,amount,fee,dataset)
        case "ERC20":
            return serveth.createTransactionRequestERC20(fromAddr,toAddr,amount,fee,dataset)
        case "XRP":
            return servxrp.createTransactionRequest(fromAddr,toAddr,amount,fee,dataset)
//        case "EOS":
//            return serveos.createTransactionRequest(fromAddr,toAddr,amount,fee,dataset)
        case "DOT":
            return servdot.createTransactionRequest(fromAddr,toAddr,amount,fee,dataset)
        }
        return {}
    }

    function createReplacedTransactionRequest(coinType,fromAddr,toAddr,amount,fee,utxoAmount,dataset) {
        switch (coinType) {
        case "BTC":
        case "LTC":
            return servbtc.createReplacedTransactionRequest(fromAddr,toAddr,amount,fee,utxoAmount,dataset)
        case "BCH":
        case "BSV":
            return servbch.createReplacedTransactionRequest(fromAddr,toAddr,amount,fee,utxoAmount,dataset)
        }
        return {}
    }

    function sendTransaction(coinType, txid, rawtx) {
        var rawpre
        switch (coinType) {
        case "BTC":
            servbtc.sendTransaction(txid, rawtx)
            break
        case "LTC":
            servltc.sendTransaction(txid, rawtx)
            break
        case "BCH":
            rawpre = rawtx.replace(/([^:]*):[^:]*/,"$1")
            servbch.sendTransaction(txid, rawpre)
            break
        case "BSV":
            rawpre = rawtx.replace(/([^:]*):[^:]*/,"$1")
            servbsv.sendTransaction(txid, rawpre)
            break
        case "ETH":
        case "ERC20":
            serveth.sendTransaction(txid, rawtx)
            break
        case "XRP":
            servxrp.sendTransaction(txid, rawtx)
            break
//        case "EOS":
//            serveos.sendTransaction(txid, rawtx)
//            break
        case "DOT":
            servdot.sendTransaction(txid, rawtx)
            break;
        }
        //Config.debugOut("send tx: " + txid + ", " + rawtx)
    }

    function searchTransaction(coinType, txreq) {
        switch (coinType) {
        case "BTC":
            servbtc.searchTransaction(txreq)
            break
        case "LTC":
            servltc.searchTransaction(txreq)
            break
        case "BCH":
            servbch.searchTransaction(txreq)
            break
        case "BSV":
            servbsv.searchTransaction(txreq)
            break
        case "ETH":
        case "ERC20":
            serveth.searchTransaction(txreq)
            break
        case "XRP":
            servxrp.searchTransaction(txreq)
            break
//        case "EOS":
//            serveos.searchTransaction(txreq)
//            break
        case "DOT":
            servdot.searchTransaction(txreq)
            break
        }
    }

    function syncBalance(coinType, addr) {
        //console.info("sync: " + coinType + ", " + addr)
        var rc = false
        switch (coinType) {
        case "BTC":
            rc = servbtc.syncBalance(addr)
            break
        case "LTC":
            rc = servltc.syncBalance(addr)
            break
        case "ETH":
            rc = serveth.syncBalance(addr)
            break
        case "BCH":
            rc = servbch.syncBalance(addr)
            break
        case "BSV":
            rc = servbsv.syncBalance(addr)
            break
        case "XRP":
            rc = servxrp.syncBalance(addr)
            break
//        case "EOS":
//            rc = serveos.syncBalance(addr)
//            break
        case "DOT":
            rc = servdot.syncBalance(addr)
            break
        }
        if (rc === false) {
            //Theme.showToast(coinType + " " + Lang.msgServiceUnaliable)
        }
    }

    function getBestFee(coinType) {
        var fee = 0
        switch (coinType) {
        case "BTC":
            fee = servbtc.feeperbyte
            break
        case "LTC":
            fee = servltc.feeperbyte
            break
        case "BCH":
            fee = servbch.feeperbyte
            break
        case "BSV":
            fee = servbsv.feeperbyte
            break
        case "ETH":
            fee = HDMath.mul(serveth.gaslimit, serveth.gasPrice)
            fee = HDMath.weiToEth(fee)
            break
        case "ERC20":
            fee = HDMath.mul(serveth.gaslimitERC20, serveth.gasPrice)
            fee = HDMath.weiToEth(fee)
            break
        case "XRP":
            fee = servxrp.bestFee
            break
        case "DOT":
            fee = servdot.bestFee
//        case "EOS":
//            break
        }
        return fee
    }

    function calcUtxoTotalAmount(utxoset) {
        var total = 0
        try {
            var uset = JSON.parse(utxoset)
            for (var i = 0; i < uset.length; i++) {
                total += uset[i]["satoshis"]
            }
        } catch (e) {
            Theme.showToast(e)
            return 0
        }
        return total
    }

    function calcUtxoFee(utxoCount,bestFee) {
        var fee = ((191 + 36) + (utxoCount * 148)) * bestFee
        return fee
    }

    function calcUtxoTotalFee(amount,bestFee,utxoset) {
        var totalFee = calcUtxoFee(1, bestFee)
        var curAmount = 0
        var ucount = 0
        try {
            var uset = JSON.parse(utxoset)
            for (var i = 0; i < uset.length; i++) {
                if (uset[i]["confirmations"] > 0) {
                    ucount++
                    totalFee = calcUtxoFee(ucount, bestFee)
                    curAmount += uset[i]["satoshis"]
                    if (amount + totalFee <= curAmount) {
                        break
                    }
                }
            }
        } catch (e) {}
        return totalFee
    }

    function isWeitCoinType(coinType) {
        var rc = false
        switch (coinType) {
        case "ETH":
        case "ETC":
            rc = true
            break
        }
        return rc
    }

    function isUtxoCoinType(coinType) {
        var rc = false
        switch (coinType) {
        case "BTC":
        case "LTC":
        case "BCH":
        case "BSV":
            rc = true
            break
        }
        return rc
    }

    function utxoIsConfirmed(coinType,confims) {
        if (confims === -2) {
            return true
        }
        var rc = false
        switch (coinType) {
        case "BTC":
        case "LTC":
        case "BCH":
        case "BSV":
        case "ETH":
        case "ERC20":
        case "XRP":
        case "DOT":
            if (confims >= 6) { rc = true }
            break
//        case "EOS":
//            if (confims >= 6) { rc = true }
//            break
        }
        return rc
    }

    function combineLocalUtxoSet(coinType, addr, utxoset) {
        var uset = []
        var i, u, tx, utx, ntx, bfind
        try {
            // reduce local spend
            var txs = JSON.parse(Store.queryTxRecord(coinType, addr, true, 0, 10000))
            for (u = 0; u < utxoset.length; u++) {
                utx = utxoset[u]
                var bspend = false
                for (i = 0; i < txs.length; i++) {
                    tx = txs[i]
                    if (tx["status"] !== -1) {
                        continue
                    }
                    if (tx["spendtx"].indexOf(utx["txid"]) !== -1) {
                        bspend = true
                        break
                    }
                }
                if (bspend) {
                    continue
                }
                uset.push(utx)
            }
            // add local change back
            for (i = 0; i < txs.length; i++) {
                tx = txs[i]
                if (tx["status"] < -1 || tx["status"] > 0) {
                    continue
                }
                bfind = false
                for (u = 0; u < utxoset.length; u++) {
                    utx = utxoset[u]
                    if (utx["txid"] === tx["txid"]) {
                        bfind = true
                        break
                    }
                }
                if (bfind) {
                    continue
                }
                var am = Config.coinsAmountValue(tx["amount"], coinType)
                var fee = Config.coinsAmountValue(tx["fee"], coinType)
                var uam = parseFloat(tx["utxoamount"])
                if (am + fee >= uam) {
                    continue
                }
                ntx = {}
                ntx["txid"] = tx["txid"]
                ntx["vout"] = 1
                ntx["satoshis"] = uam - am - fee
                ntx["confirmations"] = 0
                uset.push(ntx)
            }
            // add local receive
            txs = JSON.parse(Store.queryTxRecord(coinType, addr, false, 0, 10000))
            for (i = 0; i < txs.length; i++) {
                tx = txs[i]
                if (tx["status"] !== -1) {
                    continue
                }
                bfind = false
                for (u = 0; u < utxoset.length; u++) {
                    utx = utxoset[u]
                    if (utx["txid"] === tx["txid"]) {
                        bfind = true
                        break
                    }
                }
                if (bfind) {
                    continue
                }
                var amount = Config.coinsAmountValue(tx["amount"], coinType)
                ntx = {}
                ntx["txid"] = tx["txid"]
                ntx["vout"] = 0
                ntx["satoshis"] = amount
                ntx["confirmations"] = 0
                uset.push(ntx)
            }
        } catch (e) {
            return utxoset
        }
        return uset
    }

    function combineLocalETHPendingSet(coinType, addr, pendset) {
        var uset = pendset
        var txs, i, u, tx, utx, bfind, amount, pendtx
        try {
            // add local send
            txs = JSON.parse(Store.queryTxRecord(coinType, addr, true, 0, 10000))
            for (i = 0; i < txs.length; i++) {
                tx = txs[i]
                if (tx["status"] !== -1 && tx["status"] !== 0) {
                    continue
                }
                bfind = false
                for (u = 0; u < pendset.length; u++) {
                    utx = pendset[u]
                    if (utx["txid"] === tx["txid"]) {
                        bfind = true
                        break
                    }
                }
                if (bfind) {
                    continue
                }
                pendtx = {}
                pendtx["confirmed"] = false
                pendtx["txid"]  = tx["txid"]
                pendtx["from"]  = tx["fromAddr"]
                pendtx["to"]    = tx["toAddr"]
                amount = tx["amount"]
                amount = HDMath.ethToWei(amount)
                pendtx["value"] = amount
                uset.push(pendtx)
            }
            // add local receive
            txs = JSON.parse(Store.queryTxRecord(coinType, addr, false, 0, 10000))
            for (i = 0; i < txs.length; i++) {
                tx = txs[i]
                if (tx["status"] !== -1 && tx["status"] !== 0) {
                    continue
                }
                bfind = false
                for (u = 0; u < pendset.length; u++) {
                    utx = pendset[u]
                    if (utx["txid"] === tx["txid"]) {
                        bfind = true
                        break
                    }
                }
                if (bfind) {
                    continue
                }
                pendtx = {}
                pendtx["confirmed"] = false
                pendtx["txid"]  = tx["txid"]
                pendtx["from"]  = tx["fromAddr"]
                pendtx["to"]    = tx["toAddr"]
                amount = tx["amount"]
                amount = HDMath.ethToWei(amount)
                pendtx["value"] = amount
                uset.push(pendtx)
            }
        } catch (e) {
            return pendset
        }
        return uset
    }

    function isReplacedTransaction(txid,coinType) {
        try {
            var spendtx = ""
            var utxomap = {}
            var txs = JSON.parse(Store.queryTxRecord(coinType))
            for (var i = 0; i < txs.length; i++) {
                var tx = txs[i]
                if (tx["txid"] === txid) {
                    spendtx = tx["spendtx"]
                    continue
                }
                if (tx["status"] <= 0) {
                    continue
                }
                var sl = tx["spendtx"].split(",")
                for (var j = 0; j < sl.length; j++) {
                    utxomap[sl[j]] = 1
                }
            }
            if (spendtx === "") {
                return false
            }
            var ulist = spendtx.split(",")
            for (var u = 0; u < ulist.length; u++) {
                if (utxomap[ulist[u]] === 1) {
                    return true
                }
            }
        } catch (e) {
        }
        return false
    }

    function isReplacedNonce(txid,coinType) {
        try {
            var nonce = ""
            var utxomap = {}
            var txs = JSON.parse(Store.queryTxRecord(coinType))
            var i, tx
            for (i = 0; i < txs.length; i++) {
                tx = txs[i]
                if (tx["txid"] === txid) {
                    nonce = tx["spendtx"]
                    continue
                }
                if (tx["status"] <= 0) {
                    continue
                }
            }
            if (nonce === "") {
                return false
            }
            for (i = 0; i < txs.length; i++) {
                tx = txs[i]
                if (tx["txid"] === txid) {
                    continue
                }
                if (tx["status"] <= 0) {
                    continue
                }
                if (tx["spendtx"] === nonce) {
                    return true
                }
            }
        } catch (e) {
        }
        return false
    }

    ServiceBTC {id:servbtc}
    ServiceLTC {id:servltc}
    ServiceETH {id:serveth}
    ServiceBCH {id:servbch}
    ServiceBSV {id:servbsv}
    ServiceXRP {id:servxrp}
//    ServiceEOS {id:serveos}
    ServiceDOT {id:servdot}
}
