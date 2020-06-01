import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import Theme 1.0
import "qrc:/common"
import "qrc:/pages/address"
import "qrc:/pages/history"
import "qrc:/pages/qrscan"
import "qrc:/pages/tools"
import "qrc:/pages/settings"


Rectangle {
    id: _pageMain
    color: Theme.darkColor6

    Connections {
        target: Config
        onHideHomeBar: {
            bottomBar.hide()
        }
        onShowHomeBar: {
            bottomBar.show()
        }
        onInitHomePage: {
            swipeView.currentIndex = 0
            bottomBar.currentIndex = 0
        }
        onScanAddAddress: {
            swipeView.currentIndex = 0
            bottomBar.currentIndex = 0
        }
    }

    SwipeView {
        id: swipeView
        anchors.top: parent.top
        anchors.bottom: bottomBar.top
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        currentIndex: 0
        interactive: false

        MainAddress {id: pageAddress}
        MainHistory {id: pageHistory}
        MainTools {id: pageTools}
        MainSettings {id: pageSettings}
    }

    MainScan {
        id: pageScan
        onBackClicked: {
            Config.showHomeBar()
            pageScan.stop()
        }
    }

    MainBottom {
        id: bottomBar
        onItemClicked: {
            switch (idx) {
            case 0:
                swipeView.currentIndex = 0
                break
            case 1:
                swipeView.currentIndex = 1
                break
            case 2:
                Config.hideHomeBar()
                pageScan.start()
                break
            case 3:
                swipeView.currentIndex = 2
                break
            case 4:
                swipeView.currentIndex = 3
                break
            }
        }
    }
}
