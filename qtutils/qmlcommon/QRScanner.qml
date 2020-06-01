import QtQuick 2.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12
import HD.QRDecoder 1.0
import Theme 1.0


Rectangle {
    id: _qrscanner
    color: Theme.darkColor6
    anchors.fill: parent

    property bool active: false


    Component.onCompleted: {
        active = true
        if (camera.errorString != "") {
            Theme.showToast(camera.errorString)
        }

        if (Qt.platform.os == "windows1") {
            //var testData = 'LajiqPKxfLVSXKjWNYovxQwEUigzoi4avn'
            var testData = '
{"s":"HODL","m":"TXS","c":1,"p":1,"t":"XRP","f":"r3rhWeE31Jt5sWmi4QiGLMZnY3ENgqw96W","o":"r947gsN7MCXj61BVEJHVErd88mnu9E7s9P","a":"11","fe":"0.063009","d":"12000024003E6D3E201B034C0D10614000000000A7D8C068400000000000F621732102ED787D2512D9873A454324B4A6776608BAFAAA0E6825DEF3FFF71E0B1B89EC7674473045022100A35F2ED028AC3C923FF759FE014A385E2F3A54345DBC96E4DC3EE969C64177A802205D2F26B8492E7385ACC64264CF5FF436EF6442826D85293F01439075DC8EB31E81148CEC02D003561891772D143DE7B7C5AFAF58E8F283145BD0D77F8396276B0482A5383DC72CC6240CB0E3"}
'
            Theme.qrScanResult(testData)
        }
    }

    Component.onDestruction: {
        active = false
        camera.stop()
    }

    Camera {
        id: camera
        focus {
            focusMode: CameraFocus.FocusContinuous
            focusPointMode: CameraFocus.FocusPointCustom
            customFocusPoint: Qt.point(0.5, 0.5)
        }
    }

    VideoOutput {
       id: videoOutput
       autoOrientation: true
       source: camera
       anchors.fill: parent
       fillMode: VideoOutput.PreserveAspectCrop
    }

    Timer {
        id: timerDecode
        repeat: true
        interval: 300
        running: _qrscanner.active
        onTriggered: {
            videoOutput.grabToImage(function(result) {
                if (_qrscanner.active == false) {
                    return
                }
                QRDecoder.decodeItem(result)
            })
        }
    }

    Connections {
        target: QRDecoder
        onQrResult: {
            Theme.qrScanResult(qr)
        }
    }

    Item {
        id: itemFrame
        width: videoOutput.width>videoOutput.height?videoOutput.height*0.75:videoOutput.width*0.75
        height: width
        anchors.top: videoOutput.top
        anchors.topMargin: (videoOutput.height - height) * 0.3
        anchors.horizontalCenter: videoOutput.horizontalCenter
        Rectangle {
            radius: 1
            color: "#ffffff"
            width: parent.width * 0.07
            height: 2
        }
        Rectangle {
            radius: 1
            color: "#ffffff"
            width: 2
            height: parent.width * 0.07
        }
        Rectangle {
            anchors.bottom: parent.bottom
            radius: 1
            color: "#ffffff"
            width: parent.width * 0.07
            height: 2
        }
        Rectangle {
            anchors.bottom: parent.bottom
            radius: 1
            color: "#ffffff"
            width: 2
            height: parent.width * 0.07
        }
        Rectangle {
            anchors.right: parent.right
            radius: 1
            color: "#ffffff"
            width: parent.width * 0.07
            height: 2
        }
        Rectangle {
            anchors.right: parent.right
            radius: 1
            color: "#ffffff"
            width: 2
            height: parent.width * 0.07
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            radius: 1
            color: "#ffffff"
            width: parent.width * 0.07
            height: 2
        }
        Rectangle {
            anchors.bottom: parent.bottom
            anchors.right: parent.right
            radius: 1
            color: "#ffffff"
            width: 2
            height: parent.width * 0.07
        }
        SequentialAnimation {
            loops: Animation.Infinite
            running: true
            PropertyAnimation {
                target: itemFrame
                property: "opacity";
                from: 0.6
                to: 0.1
                easing.type: Easing.InOutSine
                duration: 1100
            }
            PauseAnimation { duration: 100 }
            PropertyAnimation {
                target: itemFrame
                property: "opacity";
                from: 0.1
                to: 0.6
                easing.type: Easing.InOutSine
                duration: 1100
            }
            PauseAnimation { duration: 100 }
        }
    }
}
