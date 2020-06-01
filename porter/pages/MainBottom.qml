import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


Item {
    id: _bottomBar
    anchors.bottom: parent.bottom
    anchors.left: parent.left
    width: parent.width
    height: Theme.pw(0.15)
    clip: false

    property int currentIndex: 0

    signal itemClicked(int idx)

    function show() {
        content.y = 0
    }
    function hide() {
        content.y = height * 1.5
    }

    onCurrentIndexChanged: {
        if (currentIndex == 1) {
            colorRect.x = Qt.binding(function(){return item2.x})
        } else if (currentIndex == 3) {
            colorRect.x = Qt.binding(function(){return item4.x})
        } else if (currentIndex == 4) {
            colorRect.x = Qt.binding(function(){return item5.x})
        } else {
            colorRect.x = Qt.binding(function(){return item1.x})
        }
    }

    Connections {
        target: Config
        onInitHomePage: {
            currentIndex = 0
        }
    }

    Rectangle {
        id: content
        color: Theme.darkColor2
        width: parent.width
        height: parent.height
        x: 0
        y: 0
        Behavior on y {
            PropertyAnimation{
                easing.type: Easing.InOutQuart
                duration: 288
            }
        }

        Rectangle {
            id: roundBack
            color: content.color
            width: parent.height * 1.82
            height: width
            anchors.centerIn: parent
            radius: width * 0.5
        }

        Rectangle {
            id: colorRect
            color: Theme.darkColor1
            width: Theme.pw(0.2) - Theme.pw(0.007)
            height: parent.height
            anchors.bottom: parent.bottom
            radius: Theme.pw(0.014)
            x: item1.x
            Behavior on x {
                PropertyAnimation{
                    easing.type: Easing.OutBack
                    duration: 288
                }
            }
        }

        MouseArea {
            id: item1
            width: Theme.pw(0.2) - Theme.pw(0.007)
            height: parent.height
            anchors.right: item2.left
            anchors.bottom: parent.bottom
            Image {
                id: image1
                width: parent.width
                height: parent.height
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: height * 0.06
                fillMode: Image.PreserveAspectFit
                source: "qrc:/images/PorterIcon.png"
                scale: 0.6
                mipmap: true
                Behavior on scale {
                    PropertyAnimation{
                        easing.type: Easing.OutBack
                        duration: 188
                    }
                }
            }
            onPressed: { image1.scale = 0.75 }
            onReleased: { image1.scale = 0.6 }
            onClicked: {
                currentIndex = 0
                itemClicked(0)
            }
        }

        MouseArea {
            id: item2
            width: Theme.pw(0.2) - Theme.pw(0.007)
            height: parent.height
            anchors.right: item3.left
            anchors.bottom: parent.bottom
            Image {
                id: image2
                width: parent.width
                height: parent.height
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: height * 0.06
                fillMode: Image.PreserveAspectFit
                source: Store.Theme > 1 ? "qrc:/images/HistoryIconDark.png" : "qrc:/images/HistoryIcon.png"
                scale: 0.6
                mipmap: true
                Behavior on scale {
                    PropertyAnimation{
                        easing.type: Easing.OutBack
                        duration: 188
                    }
                }
            }
            onPressed: { image2.scale = 0.75 }
            onReleased: { image2.scale = 0.6 }
            onClicked: {
                currentIndex = 1
                itemClicked(1)
            }
        }

        MouseArea {
            id: item3
            width: Theme.pw(0.2) + Theme.pw(0.028)
            height: parent.height
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            Image {
                id: image3
                width: parent.width
                height: parent.height
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: height * 0.15
                fillMode: Image.PreserveAspectFit
                source: Store.Theme > 1 ? "qrc:/images/QRScanIconDark.png" : "qrc:/images/QRScanIcon.png"
                mipmap: true
                Behavior on scale {
                    PropertyAnimation{
                        easing.type: Easing.OutBack
                        duration: 188
                    }
                }
            }
            onPressed: { image3.scale = 1.05 }
            onReleased: { image3.scale = 1 }
            onClicked: {
                itemClicked(2)
            }
        }

        MouseArea {
            id: item4
            width: Theme.pw(0.2) - Theme.pw(0.007)
            height: parent.height
            anchors.left: item3.right
            anchors.bottom: parent.bottom
            Image {
                id: image4
                width: parent.width
                height: parent.height
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: height * 0.06
                fillMode: Image.PreserveAspectFit
                source: Store.Theme > 1 ? "qrc:/images/ToolsIconDark.png" : "qrc:/images/ToolsIcon.png"
                scale: 0.46
                mipmap: true
                Behavior on scale {
                    PropertyAnimation{
                        easing.type: Easing.OutBack
                        duration: 188
                    }
                }
            }
            onPressed: { image4.scale = 0.6 }
            onReleased: { image4.scale = 0.46 }
            onClicked: {
                currentIndex = 3
                itemClicked(3)
            }
        }

        MouseArea {
            id: item5
            width: Theme.pw(0.2) - Theme.pw(0.007)
            height: parent.height
            anchors.left: item4.right
            anchors.bottom: parent.bottom
            Image {
                id: image5
                width: parent.width
                height: parent.height
                anchors.left: parent.left
                anchors.bottom: parent.bottom
                anchors.bottomMargin: height * 0.06
                fillMode: Image.PreserveAspectFit
                source: Store.Theme > 1 ? "qrc:/images/SettingsIconDark.png" : "qrc:/images/SettingsIcon.png"
                scale: 0.5
                mipmap: true
                Behavior on scale {
                    PropertyAnimation{
                        easing.type: Easing.OutBack
                        duration: 188
                    }
                }
            }
            onPressed: { image5.scale = 0.65 }
            onReleased: { image5.scale = 0.5 }
            onClicked: {
                currentIndex = 4
                itemClicked(4)
            }
        }
    }
}
