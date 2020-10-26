import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"
import "qrc:/pages/key"


Item {
    id: _pageWelcome

    signal nextClicked()

    Connections {
        target: Config
        onInitWelcomePage: {
            while (stackWelcome.depth > 1) {
                stackWelcome.pop()
            }
        }
    }

    MouseArea { anchors.fill: parent }

    StackView {
        id: stackWelcome
        anchors.fill: parent
        initialItem: pageWelcome
    }

    EntropyGenerate {
        id: pageEntropyGenerate
        visible: false
        onBackClicked: {
            if (stackWelcome.depth > 1) {
                stackWelcome.pop()
            }
        }
        onNextClicked: {
            if (stackWelcome.depth == 2) {
                pageEntropyBackup.loadEntropy()
                stackWelcome.push(pageEntropyBackup)
            }
        }
    }

    EntropyBackup {
        id: pageEntropyBackup
        visible: false
        onBackClicked: {
            if (stackWelcome.depth > 2) {
                stackWelcome.pop()
            }
        }
        onNextClicked: {
            _pageWelcome.nextClicked()
            pageEntropyGenerate.clearMemory()
        }
    }

    EntropyRestore {
        id: pageEntropyRestore
        visible: false
        onBackClicked: {
            if (stackWelcome.depth > 1) {
                stackWelcome.pop()
            }
        }
        onNextClicked: {
            if (stackWelcome.depth > 1) {
                stackWelcome.pop()
            }
            _pageWelcome.nextClicked()
        }
    }

    Rectangle {
        id: pageWelcome
        visible: false
        color: Theme.darkColor6

        Label {
            id: textVer
            text: Lang.appTitle + " " + Lang.appVersion
            color: Theme.lightColor1
            font.pointSize: Theme.miniSize
            anchors.right: parent.right
            anchors.rightMargin: Theme.mm(2)
            anchors.top: parent.top
            anchors.topMargin: Theme.mm(2)
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignRight
            //width: paintedWidth
            //height: paintedHeight
        }

        Image {
            id: imageIcon
            source: "qrc:/images/KeyIcon.png"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.topMargin: Theme.ph(0.04)
            width: Theme.pw(0.45)
            height: width
            fillMode: Image.PreserveAspectFit
        }

        QButton {
            id: btnInitialize
            text: Lang.txtInitialize
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: imageIcon.bottom
            anchors.topMargin: Theme.ph(0.08)
            onClicked: {
                pageEntropyGenerate.clearMemory()
                stackWelcome.push(pageEntropyGenerate)
            }
        }

        QButton {
            id: btnRestore
            text: Lang.txtRestore
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: btnInitialize.bottom
            anchors.topMargin: Theme.ph(0.05)
            onClicked: {
                stackWelcome.push(pageEntropyRestore)
            }
        }
    }
}
