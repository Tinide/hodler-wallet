import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Item {
    id: _ERC20List


    signal transferClicked(string tcontract, string tname, string tsymbol, string tdecimal, string tbalance)


    function loadERC20List(ercdat) {
        modelERC20.clear()

        try {
            var jdat = JSON.parse(ercdat)
            for (var i = 0; i < jdat["erc20"].length; i++) {
                var titem = jdat["erc20"][i]
                var contract = titem["token_address"]
                var tname    = titem["token_name"]
                var tsymbol  = titem["token_symbol"]
                var tdecimal = titem["token_decimals"]
                var tbalance = titem["balance"]

                modelERC20.append({tc: contract, tn: tname, ts: tsymbol, td: tdecimal, tb: tbalance})
            }
        } catch (e) {}
    }

    ListModel {
        id: modelERC20
    }

    ListView {
        id: listERC20
        clip: true
        width: parent.width
        height: parent.height
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        ScrollBar.vertical: ScrollBar {}
        model: modelERC20
        delegate: ERC20ListItem {
            width: listERC20.width
            height: Theme.ph(0.077)
            contract: tc
            tokenName: tn
            tokenBalance: tb
            tokenDecimals: td
            symbolName: ts
            onClicked: {
                transferClicked(tc, tn, ts, td, tb)
            }
        }
        footer: Item {
            width: listERC20.width
            height: bottomBar.height * 0.36
        }
    }
}
