import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageBlockList
    color: Theme.darkColor6
    visible: false
    opacity: 0

    signal backClicked()


    function show() {
        visible = true
        opacity = 1
        initPage()
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
    }

    Behavior on opacity {
        PropertyAnimation {
            easing.type: Easing.InOutQuad
            duration: 150
        }
    }

    SequentialAnimation {
        id: actionFadeout
        running: false

        PauseAnimation { duration: 150 }
        PropertyAction {
            target: _pageBlockList
            property: "visible"
            value: false
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: {
        }
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtBlockExplorer
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    function initPage() {
        listModel.clear()
        for (var i = 0; i < agent.servList.length; i++) {
            listModel.append({id: i, ct: agent.servList[i].coinType, st: agent.servList[i].status})
        }
    }

    ListModel { id: listModel }
    QList {
        id: listTools
        width: parent.width
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
        model: listModel
        delegate: ApiServiceListItem {
            width: listTools.width
            height: Theme.ph(0.077)
            coinType: ct
            labelText: Config.coinName(ct)
            onClicked: {
                pageBlockExplorer.coinType = ct
                pageBlockExplorer.serviceID = id
                pageBlockExplorer.show()
            }
        }
    }

    BlockExplorer {
        id: pageBlockExplorer
        anchors.fill: parent
        onBackClicked: {
            pageBlockExplorer.hide()
        }
    }
}
