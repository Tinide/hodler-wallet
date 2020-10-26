pragma Singleton
import QtQuick 2.12
import QtQuick.Window 2.12

QtObject {
    id: _theme

    signal showToast(string msg)
    signal qrScanResult(string qrd)

    property real appWidth: mm(116)
    property real appHeight: mm(177)
    property real appScale: 1
    property int  appX: 0
    property int  appY: 0
    property int  animateDuration: 70
    property real pixelRatio: 1

    property color disableColor: "#aa333333"
    property color lightColor1: "#CDDCD4"
    property color lightColor2: "#F0CED3"
    property color lightColor3: "#F8D6C1"
    property color lightColor4: "#F1CA9D"
    property color lightColor5: "#F7931E"
    property color lightColor6: "#4BA88D"
    property color lightColor7: "#E7E4E4"
    property color lightColor8: "#E54747"
    property color  darkColor1: "#005F4E"
    property color  darkColor2: "#293F46"
    property color  darkColor3: "#593500"
    property color  darkColor4: "#555A1A"
    property color  darkColor5: "#465D21"
    property color  darkColor6: "#090909"
    property color  darkColor7: "#222222"
    property color  darkColor8: "#737373"

    property string fixedFontFamily: Qt.platform.os == "android" ? "Droid Sans Mono" : "Courier New"

    property real miniSize:   pixelRatio * 10
    property real smallSize:  pixelRatio * 12.5
    property real baseSize:   pixelRatio * 14
    property real middleSize: pixelRatio * 14.5
    property real mediumSize: pixelRatio * 16
    property real fatterSize: pixelRatio * 18
    property real largeSize:  pixelRatio * 22
    property real hugeSize:   pixelRatio * 23.5
    property real asIconSize: pixelRatio * 33.5

    property real buttonHeight: appHeight * 0.07
    property real buttonWidth: appWidth * 0.33

    property bool isDesktop: (   Qt.platform.os == "windows"
                              || Qt.platform.os == "linux"
                              || Qt.platform.os == "unix"
                              || Qt.platform.os == "osx")

    Component.onCompleted: {
        console.info("Screen.devicePixelRatio:" + Screen.devicePixelRatio)
        console.info("Screen.pixelDensity:" + Screen.pixelDensity)
        console.info("Screen.desktopAvailableWidth:" + Screen.desktopAvailableWidth)
        console.info("Screen.desktopAvailableHeight:" + Screen.desktopAvailableHeight)

        if (_theme.isDesktop) {
            _theme.appX = (Screen.desktopAvailableWidth - _theme.appWidth) / 2
            _theme.appY = (Screen.desktopAvailableHeight - _theme.appHeight) / 1.2
        }
        else {
            _theme.appWidth = Screen.desktopAvailableWidth
            _theme.appHeight = Screen.desktopAvailableHeight
        }

        if (Qt.platform.os == "linux") {
            appScale = 1.2
            pixelRatio = 0.9
        } else if (Qt.platform.os == "osx") {
            appScale = 0.9
        } else if (Qt.platform.os == "windows") {
            pixelRatio = 0.65
        }
    }

    function mm(v) {
        var pd = Screen.pixelDensity
        if (pd < 2) {
            pd = 2
        }
        return v * pd
    }
    function ph(v) {
        return v * _theme.appHeight
    }
    function pw(v) {
        return v * _theme.appWidth
    }
    function cameraRotation() {
        if (Qt.platform.os == "android") {
            return 270
        }
        if (Qt.platform.os == "ios") {
            return 270
        }
        return 0
    }

    function darkTheme() {
        lightColor1 = "#CDDCD4"
        lightColor2 = "#F0CED3"
        lightColor3 = "#F8D6C1"
        lightColor4 = "#F1CA9D"
        lightColor5 = "#F7931E"
        lightColor6 = "#4BA88D"
        lightColor7 = "#E7E4E4"
        lightColor8 = "#E54747"
         darkColor1 = "#005F4E"
         darkColor2 = "#293F46"
         darkColor3 = "#593500"
         darkColor4 = "#555A1A"
         darkColor5 = "#465D21"
         darkColor6 = "#090909"
         darkColor7 = "#222222"
         darkColor8 = "#737373"
    }

    function darkWarmTheme() {
        lightColor1 = "#DCDACD"
        lightColor2 = "#DDF0CE"
        lightColor3 = "#F8E8C1"
        lightColor4 = "#F1CA9D"
        lightColor5 = "#EF8E1D"
        lightColor6 = "#F2D3EB"
        lightColor7 = "#CCD3D8"
        lightColor8 = "#E57747"
         darkColor1 = "#245E23"
         darkColor2 = "#2F2E2F"
         darkColor3 = "#593500"
         darkColor4 = "#555A1A"
         darkColor5 = "#465D21"
         darkColor6 = "#090909"
         darkColor7 = "#222222"
         darkColor8 = "#696969"
    }

    function lightTheme() {
        lightColor1 = "#005F4E"
        lightColor2 = "#004A62"
        lightColor3 = "#593500"
        lightColor4 = "#737373"
        lightColor5 = "#555A1A"
        lightColor6 = "#0E0E0E"
        lightColor7 = "#29595B"
        lightColor8 = "#465D21"
         darkColor1 = "#AAE0BC"
         darkColor2 = "#E7C4A9"
         darkColor3 = "#F8D6C1"
         darkColor4 = "#9BB6C7"
         darkColor5 = "#F7931E"
         darkColor6 = "#E6F4FC"
         darkColor7 = "#D0E1E7"
         darkColor8 = "#E1AD9C"
    }
}
