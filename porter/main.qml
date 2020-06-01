import QtQuick 2.12
import QtQuick.Window 2.12
import QtQuick.Controls 2.12
import QtQuick.Controls 1.4
import QtMultimedia 5.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"
import "qrc:/pages"
import "qrc:/serviceagent"
//import "qrc:/pages/splash"


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
        mainLoading.startLoading()
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

        Config.initHomePage()
    }

    MainPage {
        id: pageMain
        anchors.fill: parent
        visible: true
    }

    ServiceAgent { id: agent }
    Toast { id: toast }

    QLoading {
        id: mainLoading
        anchors.fill: parent
        function startLoading() {
            if (Qt.platform.os == "windows") {
                mainLoadingTimer.start()
                mainLoading.show()
            }
        }
        Timer {
            id: mainLoadingTimer
            interval: 3000
            onTriggered: {
                mainLoading.hide()
            }
        }
    }
}
