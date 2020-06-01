import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageApiServiceList
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property string coinType: "BTC"
    property int serviceID: 0

    signal backClicked()


    function show() {
        initPage()
        visible = true
        opacity = 1
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
            target: _pageApiServiceList
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
        textTitle: Lang.txtApiServiceStatus
        textLeft: Lang.txtBack
        iconRightSource: Config.coinIconSource(coinType)
        onLeftClicked: {
            backClicked()
        }
    }

    function initPage() {
        listModel.clear()
        var servList = agent.servList[serviceID].servList
        for (var i = 0; i < servList.length; i++) {
            listModel.append({dm: servList[i].name, ss: servList[i].status, cd: servList[i].canDelete})
        }
    }

    function refreshList() {
        var servList = agent.servList[serviceID].servList
        for (var i = 0; i < servList.length; i++) {
            listModel.set(i, {dm: servList[i].name, ss: servList[i].status, cd: servList[i].canDelete})
        }
    }

    Timer {
        id: timerRefresh
        running: parent.visible
        repeat: true
        interval: 2000
        onTriggered: {
            refreshList()
        }
    }

    Connections {
        target: Store
        onServiceAdded: {
            refreshList()
        }
    }

    ListModel { id: listModel }
    QList {
        id: listTools
        width: parent.width
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
        model: listModel
        delegate: QListItem {
            width: listTools.width
            height: Theme.ph(0.077)
            leftText: dm
            rightText: ss
            rightIcon.visible: false
            onClicked: {
                if (cd === false) {
                    return
                }
                dialogDelete.serviceIndex = index
                dialogDelete.show()
            }
        }
        footer: Component {
            Rectangle {
                id: rectFooter
                visible: {
                    if (   coinType == "BTC" || coinType == "LTC"
                        || coinType == "BCH") {
                        //|| coinType == "BCH" || coinType == "BSV") {
                        return true
                    }
                    return false
                }
                color: Theme.darkColor7
                width: listTools.width
                height: Theme.ph(0.077)
                Image {
                    id: iconLeft
                    width: parent.height
                    height: width
                    anchors.centerIn: parent
                    source: Store.Theme == 0 ? "qrc:/images/AddIcon.png" : "qrc:/images/AddIconDark.png"
                    mipmap: true
                    fillMode: Image.PreserveAspectFit
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        pageAddService.coinType = coinType
                        pageAddService.show()
                    }
                    onPressed: {
                        animationPress.start()
                    }
                }
                SequentialAnimation {
                    id: animationPress
                    ColorAnimation {
                        target: rectFooter
                        property: "color"
                        from: Theme.darkColor7
                        to: Theme.darkColor8
                        duration: 150
                    }
                    ColorAnimation {
                        target: rectFooter
                        property: "color"
                        from: Theme.darkColor8
                        to: Theme.darkColor7
                        duration: 140
                    }
                }
            } // Rectangle
        } // footer
    } // QList

    AddApiService {
        id: pageAddService
        anchors.fill: parent
        onBackClicked: {
            pageAddService.hide()
        }
    }

    QDialog {
        id: dialogDelete
        content.height: Theme.ph(0.33)
        content.anchors.topMargin: Theme.ph(0.3)
        property int serviceIndex: 0

        Label {
            id: txtDeleteTip
            text: Lang.txtDeleteService
            color: Theme.darkColor6
            font.pointSize: Theme.baseSize
            width: dialogDelete.content.width * 0.8
            height: dialogDelete.content.height * 0.5
            anchors.horizontalCenter: dialogDelete.content.horizontalCenter
            anchors.top: dialogDelete.content.top
            anchors.bottom: btnConfirm.top
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
        }

        QButton {
            id: btnConfirm
            text: Lang.txtConfirm
            anchors.left: dialogDelete.content.left
            anchors.leftMargin: Theme.pw(0.03)
            anchors.bottom: dialogDelete.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                var servList = agent.servList[serviceID].servList
                Store.deleteService(servList[dialogDelete.serviceIndex].domain, servList[dialogDelete.serviceIndex].port)
                listModel.remove(dialogDelete.serviceIndex)
                dialogDelete.hide()
            }
        }

        QButton {
            id: btnCancel
            text: Lang.txtCancel
            anchors.right: dialogDelete.content.right
            anchors.rightMargin: Theme.pw(0.03)
            anchors.bottom: dialogDelete.content.bottom
            anchors.bottomMargin: Theme.pw(0.03)
            onClicked: {
                dialogDelete.hide()
            }
        }
    }
}
