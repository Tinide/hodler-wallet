import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4
import QtMultimedia 5.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"
import "qrc:/pages"
import "qrc:/pages/splash"
import "qrc:/pages/key"


Window {
    id: windowMain
    visible: true
    x: Theme.appX
    y: Theme.appY
    width: Theme.appWidth
    height: Theme.appHeight
    title: Lang.appTitle
    color: Theme.darkColor6

    Component.onCompleted: {
        switch (Store.Theme) {
        case 0:
            Theme.darkTheme()
            break
        case 1:
            Theme.darkWarmTheme()
            break
        case 2:
            Theme.lightTheme()
            break
        }
        if (Store.Language != 0) {
            Lang.languageIndex = Store.Language
        }
        if (Store.FontSize < 0) {
            Store.FontSize = Theme.pixelRatio * 100
        } else {
            Theme.pixelRatio = Store.FontSize / 100
        }

        loadMainTabView()
    }

    function loadMainTabView() {
        if (Key.hasMac()) {
            pageFirstUnlock.visible = true
            swipeViewMain.currentIndex = 2
        }
        else {
            pageSplash.visible = true
            swipeViewMain.currentIndex = 0
        }
        swipeViewMain.visible = true
    }

    Connections {
        target: Config
        onRequestPin: {
            pageUnlock.callback = cb
            pageUnlock.visible = true
        }
        onResetAll: {
            pageSplash.visible = true
            Key.setMac("")
            Store.clearStore()
            swipeViewMain.currentIndex = 0
        }
    }

    SwipeView {
        id: swipeViewMain
        anchors.fill: parent
        visible: false
        interactive: false

        SetLock {
            z: 1000
            onClicked: {
                if (Key.hasEntropy()) {
                    swipeViewMain.currentIndex = 2
                    Config.initHomePage()
                } else {
                    swipeViewMain.currentIndex = 1
                    Config.initWelcomePage()
                }
            }
        }
        Welcome {
            z: 500
            onNextClicked: {
                swipeViewMain.currentIndex = 2
                Config.initHomePage()
            }
        }
        MainPage {z: 1}
    }

    Unlock {
        id: pageUnlock
        anchors.fill: parent
        visible: false
        onClicked: {
            pageUnlock.visible = false
        }
        onAllReset: {
            loadMainTabView()
            pageUnlock.visible = false
        }
    }

    Unlock {
        id: pageFirstUnlock
        anchors.fill: parent
        visible: false
        onClicked: {
            if (Key.hasEntropy()) {
                swipeViewMain.currentIndex = 2
                Config.initHomePage()
            } else {
                swipeViewMain.currentIndex = 1
                Config.initWelcomePage()
            }
            pageFirstUnlock.visible = false
        }
        onAllReset: {
            loadMainTabView()
            pageFirstUnlock.visible = false
        }
    }

    Splash {
        id: pageSplash
        visible: false
        anchors.fill: parent
        onClicked: {
            pageSplash.visible = false
        }
    }

    Toast { id: toast }
}
