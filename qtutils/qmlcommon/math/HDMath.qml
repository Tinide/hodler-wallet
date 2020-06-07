pragma Singleton
import QtQuick 2.12
import "qrc:/common/math/Math.js" as Ma


QtObject {
    id: _hdmath

    function add(v1,v2) { return Ma.add(v1, v2) }
    function sub(v1,v2) { return Ma.sub(v1, v2) }
    function mul(v1,v2) { return Ma.mul(v1, v2) }
    function div(v1,v2) { return Ma.div(v1, v2) }
    function fdiv(v1,v2) { return Ma.fdiv(v1, v2) }
    function pow(v1,v2) { return Ma.pow(v1, v2) }
    function cmp(v1,v2) { return Ma.cmp(v1, v2) }
    function toString(v) { return Ma.toString(v) }

    function satToBtc(sat) { return Ma.satToBtc(sat) }
    function btcToSat(btc) { return Ma.btcToSat(btc) }

    function weiToEth(wei)   { return Ma.weiToEth(wei)   }
    function weiToGwei(wei)  { return Ma.weiToGwei(wei)  }
    function gweiToEth(gwei) { return Ma.gweiToEth(gwei) }
    function gweiToWei(gwei) { return Ma.gweiToWei(gwei) }
    function ethToWei(eth)   { return Ma.ethToWei(eth)   }
    function ethToGwei(eth)  { return Ma.ethToGwei(eth)  }

    function dropToXrp(drop) { return Ma.dropToXrp(drop) }
    function xrpToDrop(xrp)  { return Ma.xrpToDrop(xrp)  }

    function toCashLegacy(addr)  { return Ma.toCashLegacy(addr) }
    function toCashAddress(addr) { return Ma.toCashAddress(addr) }
}
