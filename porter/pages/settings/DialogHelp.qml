import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageHelp
    color: Theme.darkColor6
    anchors.fill: parent
    visible: false
    opacity: 0


    signal backClicked()

    function show() {
        visible = true
        opacity = 1

        listModel.clear()
        listModel.append({lt: "1. " + Lang.txtHelp1, rt: ""})
        listModel.append({lt: "2. " + Lang.txtHelp2, rt: ""})
        listModel.append({lt: "3. " + Lang.txtHelp3, rt: ""})
        listModel.append({lt: "4. " + Lang.txtHelp4, rt: ""})
        listModel.append({lt: "5. " + Lang.txtHelp5, rt: ""})
    }

    function hide() {
        opacity = 0
        actionFadeout.running = true
    }

    Behavior on opacity {
        PropertyAnimation{
            easing.type: Easing.InOutQuad
            duration: 150
        }
    }

    SequentialAnimation {
        id: actionFadeout
        running: false

        PauseAnimation { duration: 150 }
        PropertyAction {
            target: _pageHelp
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtHelp
        textLeft: Lang.txtBack
        onLeftClicked: {
            backClicked()
        }
    }

    ListModel { id: listModel }
    QList {
        id: listHelp
        width: parent.width
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
        model: listModel
        delegate: QListItem {
            width: listTools.width
            height: Theme.ph(0.077)
            leftText: lt
            rightText: rt
            onClicked: {
                switch (index) {
                case 0:
                    dialogHelp1.show()
                    break
                case 1:
                    dialogHelp2.show()
                    break
                case 2:
                    dialogHelp3.show()
                    break
                case 3:
                    dialogHelp4.show()
                    break
                case 4:
                    dialogHelp5.show()
                    break
                }
            }
        }
    }

    DialogHelpSub1 {
        id: dialogHelp1
        onBackClicked: {
            dialogHelp1.hide()
        }
    }

    DialogHelpSub2 {
        id: dialogHelp2
        onBackClicked: {
            dialogHelp2.hide()
        }
    }

    DialogHelpSub3 {
        id: dialogHelp3
        onBackClicked: {
            dialogHelp3.hide()
        }
    }

    DialogHelpSub4 {
        id: dialogHelp4
        onBackClicked: {
            dialogHelp4.hide()
        }
    }

    DialogHelpSub5 {
        id: dialogHelp5
        onBackClicked: {
            dialogHelp5.hide()
        }
    }
}
