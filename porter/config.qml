pragma Singleton
import QtQuick 2.12
import Theme 1.0
import HD.Language 1.0


QtObject {
    id: _config

    signal initHomePage()
    signal hideHomeBar()
    signal showHomeBar()
    signal languageChanged()
    signal scanAddAddress(string addr, string label, string ct)
    signal balanceResult(string addr, string ba, string pa, string ta, string dat)
    signal transactionResult(string td, string result)

    property bool debugMode: false
    property string rpcLocal: "127.0.0.1"
    property int  rpcLocalPort: 35911
    property bool rpcLocalTls: true
    property bool mainnet: true
    property int  pingInterval: 30000
    property int  satmul: 100000000


    function debugOut(txt) {
        if (debugMode) {
            console.info(txt)
        }
    }

    function parseAddressType(addrstr) {
        var addr = addrstr.toLowerCase()
        if (addr.startsWith("litecoin:")) {
            return "LTC"
        } else if (addr.startsWith("ethereum:")) {
            return "ETH"
        } else if (addr.startsWith("bitcoincash:")) {
            return "BCH"
        } else if (addr.startsWith("bitcoinsv:")) {
            return "BSV"
//        } else if (addr.startsWith("eos:")) {
//            return "EOS"
        } else if (addr.startsWith("ripple:")) {
            return "XRP"
        }
        addr = addrstr.replace(/[^:]*:([^:]*)/, "$1")
        if (   addr.startsWith("1")
            || addr.startsWith("3")
            || addr.startsWith("bc1")
            || addr.startsWith("2")
            || addr.startsWith("m")
            || addr.startsWith("n")
            || addr.startsWith("tb1")) {
            return "BTC"
        }
        if (   addr.startsWith("M")
            || addr.startsWith("L")
            || addr.startsWith("ltc1")) {
            return "LTC"
        }
        if (   addr.startsWith("0x")
            && addr.length === 42) {
            return "ETH"
        }
        if (   addr.startsWith("p")
            || addr.startsWith("q")) {
            return "BCH"
        }
        if (   addr.startsWith("r")) {
            return "XRP"
        }
        addr = addrstr.toLowerCase()
        if (addr.startsWith("bitcoin:")) {
            return "BTC"
        }
        return ""
    }

    function txStatusString(coinType, status) {
        var statusString = ""
        switch (status) {
        case -3:
            return Lang.txtDelTransaction
        case -2:
            return Lang.txtBadTransaction
        case -1:
            return Lang.txtStatusUnconfirmed
        }

        switch (coinType) {
        case "BTC":
        case "BCH":
        case "BSV":
        case "ETH":
        case "ERC20":
        case "XRP":
        case "LTC":
//        case "EOS":
            if (status >= 6) {
                return Lang.txtStatusOK
            }
            break
        }

        statusString = "" + status + " " + Lang.txtStatusConfirms
        return statusString
    }

    function normalFloatString(val) {
        val = parseFloat(val) + 0.000000001
        var amountString = "" + val.toFixed(8).toLocaleString(Qt.locale("de_DE"),'f',8)
        amountString = amountString.replace(/(0+)$/g,"")
        amountString = amountString.replace(/(\.+)$/g,"")
        return amountString
    }

    function coinsAmountString(amount, cointype) {
        var amountString = ""
        switch (cointype) {
        case "BTC":
        case "BCH":
        case "BSV":
        case "LTC":
            var val = (amount / 100000000) + 0.000000001
            amountString = "" + val.toFixed(8).toLocaleString(Qt.locale("de_DE"),'f',8)
            break
        }
        amountString = amountString.replace(/(0+)$/g,"")
        amountString = amountString.replace(/(\.+)$/g,"")
        return amountString
    }

    function coinsAmountValue(amountString, cointype) {
        var amount = 0
        switch (cointype) {
        case "BTC":
        case "BCH":
        case "BSV":
        case "LTC":
            amount = parseFloat(amountString) + 0.000000001
            amount = parseInt(amount * 100000000)
            break
        }
        return amount
    }

    function themeName(idx) {
        var name = Lang.txtDark
        switch (idx) {
        case 0:
            name = Lang.txtDark
            break
        case 1:
            name = Lang.txtDarkWarm
            break
        case 2:
            name = Lang.txtLight
            break
        }
        return name
    }

    function languageName(idx) {
        var name = Lang.txtENUS
        switch (idx) {
        case 0:
            name = Lang.txtENUS
            break
        case 1:
            name = Lang.txtJAJA
            break
        case 2:
            name = Lang.txtKOKO
            break
        case 3:
            name = Lang.txtDEDE
            break
        case 4:
            name = Lang.txtFRFR
            break
        case 5:
            name = Lang.txtITIT
            break
        case 6:
            name = Lang.txtPLPL
            break
        case 7:
            name = Lang.txtESES
            break
        case 8:
            name = Lang.txtAFAF
            break
        case 9:
            name = Lang.txtZHTW
            break
        case 10:
            name = Lang.txtZHCN
            break
        }
        return name
    }

    function coinName(coinType) {
        var name = "Bitcoin"
        switch (coinType) {
        case "BTC":
            name = "Bitcoin"
            break
        case "LTC":
            name = "Litecoin"
            break
        case "ETH":
            name = "Ethereum"
            break
        case "ETC":
            name = "Ethereum classic"
            break
        case "BCH":
            name = "Bitcoin Cash"
            break
        case "XRP":
            name = "Ripple"
            break
//        case "EOS":
//            name = "EOS"
//            break
        case "BSV":
            name = "Bitcoin SV"
            break
        }
        return name
    }

    function coinAddrPrefix(coinType) {
        var prefix = ""
        switch (coinType) {
        case "BTC":
            prefix = "bitcoin:"
            break
        case "LTC":
            prefix = "litecoin:"
            break
        case "ETH":
            prefix = "ethereum:"
            break
        case "ETC":
            prefix = "etc:"
            break
        case "BCH":
            prefix = "bitcoincash:"
            break
        case "XRP":
            prefix = "ripple:"
            break
//        case "EOS":
//            prefix = "eos:"
//            break
        case "BSV":
            prefix = "bitcoinsv:"
            break
        }
        return prefix
    }

    function coinColor(coinType) {
        var clr = Theme.lightColor5
        switch (coinType) {
        case "BTC":
            clr = Theme.lightColor4
            break
        case "LTC":
            clr = Theme.lightColor1
            break
        case "ETH":
            clr = Theme.lightColor7
            break
        case "ETC":
            clr = Theme.lightColor2
            break
        case "BCH":
            clr = Theme.lightColor6
            break
        case "XRP":
            clr = Theme.lightColor7
            break
//        case "EOS":
//            clr = Theme.lightColor1
//            break
        case "BSV":
            clr = Theme.lightColor5
            break
        }
        return clr
    }

    function coinIconSource(coinType) {
        var iconSource = "qrc:/images/IconBitcoin.png"
        switch (coinType) {
        case "BTC":
            iconSource = "qrc:/images/IconBitcoin.png"
            break
        case "LTC":
            iconSource = "qrc:/images/IconLitecoin.png"
            break
        case "ETH":
        case "ERC20":
            iconSource = "qrc:/images/IconEthereum.png"
            break
        case "BCH":
            iconSource = "qrc:/images/IconBitcoinCash.png"
            break
        case "XRP":
            iconSource = "qrc:/images/IconRipple.png"
            break
//        case "EOS":
//            iconSource = "qrc:/images/IconEOS.png"
//            break
        case "BSV":
            iconSource = "qrc:/images/IconBitcoinSV.png"
            break
        }
        return iconSource
    }

    function entropyAddressMethod(coinType) {
        var method = "BTC.EntropyToAddress"
        switch (coinType) {
        case "BTC":
        case "LTC":
        case "BCH":
        case "BSV":
        case "ETH":
        case "XRP":
            method = coinType + ".EntropyToAddress"
            break
//        case "EOS":
//            method = "EOS.EntropyToPublicKey"
//            break
        }
        return method
    }
}
