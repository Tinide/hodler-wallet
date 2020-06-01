import QtQuick 2.9
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _item
    color: Theme.darkColor7

    property string coinType: "BTC"
    property string status: ""
    property alias labelText: labelLabel.text
    property bool canDelete: false

    signal clicked()

    Image {
        id: imgToken
        anchors.left: parent.left
        anchors.leftMargin: parent.width * 0.01
        height: parent.height * 0.8
        width: height
        anchors.verticalCenter: parent.verticalCenter
        source: Config.coinIconSource(coinType)
        mipmap: true
    }

//    Rectangle {
//        id: lineSpace1
//        width: Theme.mm(0.21)
//        height: parent.height * 0.8
//        anchors.left: imgToken.right
//        anchors.leftMargin: parent.width * 0.02
//        anchors.verticalCenter: parent.verticalCenter
//        color: Theme.darkColor8
//    }

    Label {
        id: labelLabel
        anchors.left: imgToken.right
        anchors.leftMargin: parent.width * 0.04
        width: parent.width * 0.5
        height: parent.height
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
        font.pointSize: Theme.baseSize
        color: Config.coinColor(coinType)
        //elide: Text.ElideRight
        text: Config.coinName(coinType) + " " + Lang.txtService + " - " + status
    }

    Label {
        id: iconRight
        height: parent.height
        width: paintedWidth
        anchors.verticalCenter: parent.verticalCenter
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.rightMargin: Theme.pw(0.05)
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: Theme.lightColor1
        font.pointSize: Theme.mediumSize
        font.family: Theme.fixedFontFamily
        text: ">"
    }

    Rectangle {
        id: lineBottom
        width: parent.width
        height: Theme.mm(0.21)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        color: Theme.darkColor8
    }

    SequentialAnimation {
        id: animationPress
        ColorAnimation {
            target: _item
            property: "color"
            from: Theme.darkColor7
            to: Theme.darkColor8
            duration: 150
        }
        ColorAnimation {
            target: _item
            property: "color"
            from: Theme.darkColor8
            to: Theme.darkColor7
            duration: 140
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
            _item.clicked()
        }
        onPressed: {
            animationPress.start()
        }
    }
}
