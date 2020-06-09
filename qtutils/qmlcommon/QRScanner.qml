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
