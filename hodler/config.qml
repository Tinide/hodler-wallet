pragma Singleton
import QtQuick 2.12
import Theme 1.0
import HD.Language 1.0


QtObject {
    id: _config

    property string rpcLocal: "127.0.0.1"
    property int    rpcLocalPort: 34911
    property bool   rpcLocalTls: true

    property string seed: ""
    property int  m1: 20202064
    property int  m2: 0
    property bool compressPubkey: true
    property bool mainnet: true
    property int  addrPageItems: 1
    property int  maxAddrs: 1000

    signal requestPin(var cb)
    signal resetAll()
    signal initWelcomePage()
    signal initHomePage()
    signal hideHomeBar()
    signal showHomeBar()
    signal historyChanged()
    signal languageChanged()


    function coinsM1(coinType) {
        var val = 0
        switch (coinType) {
        case "BTC":
            val = 20202064
            break
        case "LTC":
            val = 20202065
            break
        case "ETH":
        case "ERC20":
            val = 20202066
            break
        case "ETC":
            val = 20202067
            break
        case "BCH":
            val = 20202068
            break
        case "XRP":
            val = 20202069
            break
        case "EOS":
            val = 20202070
            break
        case "BSV":
            val = 20202071
            break
        }
        return val
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
        case "EOS":
            name = "EOS"
            break
        case "BSV":
            name = "Bitcoin SV"
            break
        }
        return name
    }

    function coinAddrPrefix(coinType) {
        var prefix = "Bitcoin"
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
        case "EOS":
            prefix = "eos:"
            break
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
        case "ERC20":
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
        case "EOS":
            clr = Theme.lightColor1
            break
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
        case "EOS":
            iconSource = "qrc:/images/IconEOS.png"
            break
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
        case "ERC20":
            method = "ETH.EntropyToAddress"
            break
        case "EOS":
            method = "EOS.EntropyToPublicKey"
            break
        }
        return method
    }
}
