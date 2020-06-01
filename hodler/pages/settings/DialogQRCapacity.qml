import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


QDialog {
    id: _dialogCapacity
    anchors.fill: parent
    content.height: Theme.ph(0.4)


    signal confirmed(int cap)


    Connections {
        target: Config
        onInitHomePage: {
            sliderCapacity.slider.value = Store.QRCapacity
        }
    }

    Label {
        id: txtTitle
        text: Lang.txtQRCapacityTip
        color: Theme.darkColor2
        font.pointSize: Theme.mediumSize
        width: _dialogCapacity.content.width
        height: paintedHeight * 3
        anchors.top: _dialogCapacity.content.top
        anchors.left: _dialogCapacity.content.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        id: txtBytes
        text: "" + sliderCapacity.slider.value + " " + Lang.txtBytes
        color: Theme.darkColor3
        font.pointSize: Theme.middleSize
        width: _dialogCapacity.content.width
        height: paintedHeight * 2
        anchors.top: txtTitle.bottom
        anchors.left: _dialogCapacity.content.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    QSlider {
        id: sliderCapacity
        width: Theme.pw(0.6)
        height: Theme.ph(0.06)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: txtBytes.bottom
        slider.minimumValue: 256
        slider.maximumValue: 1024
        slider.value: 304
        slider.stepSize: 16
    }

    Label {
        id: txtMinBytes
        text: sliderCapacity.slider.minimumValue
        color: Theme.darkColor1
        font.pointSize: Theme.middleSize
        width: _dialogCapacity.content.width * 0.5
        height: paintedHeight
        anchors.top: sliderCapacity.bottom
        anchors.topMargin: sliderCapacity.height * 0.1
        anchors.left: sliderCapacity.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignLeft
    }

    Label {
        id: txtMaxBytes
        text: sliderCapacity.slider.maximumValue
        color: Theme.darkColor1
        font.pointSize: Theme.middleSize
        width: _dialogCapacity.content.width * 0.5
        height: paintedHeight
        anchors.top: sliderCapacity.bottom
        anchors.topMargin: sliderCapacity.height * 0.1
        anchors.right: sliderCapacity.right
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignRight
    }

    QButton {
        id: btnConfirrm
        text: Lang.txtConfirm
        anchors.horizontalCenter: content.horizontalCenter
        anchors.bottom: _dialogCapacity.content.bottom
        anchors.bottomMargin: Theme.pw(0.03)
        onClicked: {
            confirmed(sliderCapacity.slider.value)
        }
    }
}
