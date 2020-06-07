import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Math 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _itemERC20
    color: Theme.darkColor7

    property string contract: ""
    property string tokenName: ""
    property string tokenBalance: ""
    property string tokenDecimals: ""
    property string symbolName: ""

    signal clicked()


    Label {
        id: labelToken
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.02
        height: parent.height
        width: parent.width * 0.3
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        wrapMode: Text.Wrap
        text: tokenName
    }

    Rectangle {
        id: lineSpace1
        width: Theme.mm(0.21)
        height: parent.height * 0.8
        anchors.left: labelToken.right
        anchors.leftMargin: parent.width * 0.01
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.darkColor8
    }

    Label {
        id: labelTokenBalance
        anchors.left: lineSpace1.right
        width: parent.width * 0.5
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
        font.pointSize: Theme.baseSize
        color: Theme.lightColor1
        wrapMode: Text.Wrap
        text: {
            if (tokenBalance === "" || tokenDecimals === "" || tokenDecimals === "0") {
                return tokenBalance
            }
            var fmp = HDMath.pow(10, tokenDecimals)
            var fval = HDMath.fdiv(tokenBalance, fmp)
            return fval + " " + symbolName
        }
    }

    Rectangle {
        id: lineSpace2
        width: Theme.mm(0.21)
        height: parent.height * 0.8
        anchors.left: labelTokenBalance.right
        anchors.verticalCenter: parent.verticalCenter
        color: Theme.darkColor8
    }

    QButton {
        id: btnTransfer
        radius: 0
        height: parent.height
        anchors.left: lineSpace2.right
        anchors.right: parent.right
        text: Lang.txtSendTo
        onClicked: {
            _itemERC20.clicked()
        }

        Rectangle {
            id: lineBottom2
            width: parent.width
            height: Theme.mm(0.21)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            color: Theme.darkColor8
        }
    }

    Rectangle {
        id: lineBottom
        width: parent.width
        height: Theme.mm(0.21)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        color: Theme.darkColor8
    }
}
