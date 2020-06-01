import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageSettings
    color: Theme.darkColor6


    Connections {
        target: Config
        onInitHomePage: {
            initPage()
        }
        onLanguageChanged: {
            initPage()
        }
    }

    function initPage() {
        listModel.clear()
        listModel.append({lt: Lang.txtLanguage, rt: Config.languageName(Store.Language)})
        listModel.append({lt: Lang.txtTheme, rt: Config.themeName(Store.Theme)})
        listModel.append({lt: Lang.txtFontSize, rt: ""})
        listModel.append({lt: Lang.txtQRCapacity, rt: "" + Store.QRCapacity + " " + Lang.txtBytes})
        listModel.append({lt: Lang.txtHelp, rt: ""})
        listModel.append({lt: Lang.txtAbout, rt: ""})
    }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtSettings
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
            leftText: lt
            rightText: rt
            onClicked: {
                switch (index) {
                case 0:
                    dialogLanguage.show()
                    break
                case 1:
                    dialogTheme.show()
                    break
                case 2:
                    dialogFontSize.show()
                    break
                case 3:
                    dialogQRCapacity.show()
                    break
                case 4:
                    dialogHelp.show()
                    break
                case 5:
                    dialogAbout.show()
                    break
                }
            }
        }
    }

    DialogLanguage {
        id: dialogLanguage
        onLangClicked: {
            listModel.setProperty(0, "rt", Config.languageName(idx))
            Store.Language = idx
            Lang.languageIndex = idx
            Config.languageChanged()
            dialogLanguage.hide()
        }
    }

    DialogTheme {
        id: dialogTheme
        onThemeClicked: {
            listModel.setProperty(1, "rt", Config.themeName(idx))
            Store.Theme = idx
            dialogTheme.hide()
            switch (idx) {
            case 0: Theme.darkTheme()
                break
            case 1: Theme.darkWarmTheme()
                break
            case 2: Theme.lightTheme()
                break
            }
        }
    }

    DialogFontSize {
        id: dialogFontSize
        onConfirmed: {
            dialogFontSize.hide()
            Store.FontSize = cap
        }
        onOutsideClicked: {
            Theme.pixelRatio = Store.FontSize / 100
        }
    }

    DialogQRCapacity {
        id: dialogQRCapacity
        onConfirmed: {
            listModel.setProperty(3, "rt", "" + cap + " " + Lang.txtBytes)
            Store.QRCapacity = cap
            dialogQRCapacity.hide()
        }
    }

    DialogHelp {
        id: dialogHelp
        onBackClicked: {
            dialogHelp.hide()
        }
    }

    DialogAbout {
        id: dialogAbout
        onBackClicked: {
            dialogAbout.hide()
        }
    }
}
