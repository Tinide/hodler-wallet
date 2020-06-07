Qt.include("bignumber.js")
Qt.include("BCHaddrjs-0.4.8.min.js")


function add(v1,v2) {
    var a = new BigNumber(v1)
    var b = new BigNumber(v2)
    var c = a.plus(b).integerValue()
    return c.toString()
}

function sub(v1,v2) {
    var a = new BigNumber(v1)
    var b = new BigNumber(v2)
    var c = a.minus(b).integerValue()
    return c.toString()
}

function mul(v1,v2) {
    var a = new BigNumber(v1)
    var b = new BigNumber(v2)
    var c = a.multipliedBy(b).integerValue()
    return c.toString()
}

function div(v1,v2) {
    var a = new BigNumber(v1)
    var b = new BigNumber(v2)
    var c = a.dividedBy(b).integerValue()
    return c.toString()
}

function fdiv(v1,v2) {
    var a = new BigNumber(v1)
    var b = new BigNumber(v2)
    var c = a.dividedBy(b)
    return c.toString()
}

function pow(v1,v2) {
    var a = new BigNumber(v1)
    var b = new BigNumber(v2)
    var c = a.pow(b).integerValue()
    return c.toString()
}

function cmp(v1,v2) {
    var a = new BigNumber(v1)
    var b = new BigNumber(v2)
    var c = a.comparedTo(b)
    return c
}

function toString(v) {
    var a = new BigNumber(v)
    return a.toString()
}

function satToBtc(sat) {
    var s = new BigNumber(sat)
    var u = new BigNumber("100000000")
    var c = s.div(u)
    c = c.toFixed(8).toLocaleString(Qt.locale("de_DE"),'f',8)
    c = c.replace(/(0+)$/g,"")
    c = c.replace(/(\.+)$/g,"")
    return c
}

function btcToSat(btc) {
    var b = new BigNumber(btc)
    var u = new BigNumber("100000000")
    var c = b.div(u)
    return c.toString()
}

function weiToEth(wei) {
    var w = new BigNumber(wei)
    var u = new BigNumber("1000000000000000000")
    var c = w.div(u)
    c = c.toFixed(18).toLocaleString(Qt.locale("de_DE"),'f',18)
    c = c.replace(/(0+)$/g,"")
    c = c.replace(/(\.+)$/g,"")
    return c
}

function weiToGwei(wei) {
    var w = new BigNumber(wei)
    var u = new BigNumber("1000000000")
    var c = w.div(u)
    return c.toFixed(0)
}

function ethToWei(eth) {
    var w = new BigNumber(eth)
    var u = new BigNumber("1000000000000000000")
    var c = w.multipliedBy(u)
    return c.toString()
}

function gweiToWei(gwei) {
    var w = new BigNumber(gwei)
    var u = new BigNumber("1000000000")
    var c = w.multipliedBy(u)
    return c.toString()
}

function gweiToEth(gwei) {
    var w = new BigNumber(gwei)
    var u = new BigNumber("1000000000")
    var c = w.div(u)
    c = c.toFixed(9).toLocaleString(Qt.locale("de_DE"),'f',9)
    c = c.replace(/(0+)$/g,"")
    c = c.replace(/(\.+)$/g,"")
    return c
}

function ethToGwei(eth) {
    var w = new BigNumber(eth)
    var u = new BigNumber("1000000000")
    var c = w.multipliedBy(u)
    return c.toString()
}

function dropToXrp(drop) {
    var d = new BigNumber(drop)
    var u = new BigNumber("1000000")
    var c = d.div(u)
    c = c.toFixed(6).toLocaleString(Qt.locale("de_DE"),'f',6)
    c = c.replace(/(0+)$/g,"")
    c = c.replace(/(\.+)$/g,"")
    return c
}

function xrpToDrop(xrp)  {
    var x = new BigNumber(xrp)
    var u = new BigNumber("1000000")
    var c = x.multipliedBy(u)
    return c.toString()
}

function toCashLegacy(addr) {
    var toLegacyAddress = bchaddr.toLegacyAddress
    addr = toLegacyAddress(addr)
    return addr
}

function toCashAddress(addr) {
    var toCashAddress = bchaddr.toCashAddress
    addr = toCashAddress(addr)
    return addr.replace(/[^:]*:([^:]*)/,"$1")
}
