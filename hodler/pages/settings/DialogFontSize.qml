import QtQuick 2.12
import QtQuick.Controls 2.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Store 1.0
import Theme 1.0
import "qrc:/common"


QDialog {
    id: _dialogFontSize
    anchors.fill: parent
    content.height: Theme.ph(0.4)


    signal confirmed(int cap)


    Connections {
        target: Config
        onInitHomePage: {
            //sliderCapacity.slider.value = Store.QRCapacity
        }
    }

    Label {
        id: txtTitle
        text: Lang.txtFontSize
        color: Theme.darkColor2
        font.pointSize: Theme.mediumSize
        width: _dialogFontSize.content.width
        height: Theme.pw(0.1)
        anchors.top: _dialogFontSize.content.top
        anchors.left: _dialogFontSize.content.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    Label {
        id: txtBytes
        text: (sliderCapacity.slider.value / 100)
        color: Theme.darkColor3
        font.pointSize: Theme.middleSize
        width: _dialogFontSize.content.width
        height: Theme.pw(0.23)
        anchors.top: _dialogFontSize.content.top
        anchors.topMargin: Theme.pw(0.1)
        anchors.left: _dialogFontSize.content.left
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: Text.AlignHCenter
    }

    QSlider {
        id: sliderCapacity
        width: Theme.pw(0.6)
        height: Theme.ph(0.06)
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: _dialogFontSize.content.top
        anchors.topMargin: Theme.pw(0.3)
        slider.minimumValue: 50
        slider.maximumValue: 150
        slider.value: Theme.pixelRatio * 100
        slider.stepSize: 5
        slider.onValueChanged: {
            Theme.pixelRatio = (slider.value / 100)
        }
    }

    QButton {
        id: btnConfirrm
        text: Lang.txtConfirm
        anchors.horizontalCenter: content.horizontalCenter
        anchors.bottom: _dialogFontSize.content.bottom
        anchors.bottomMargin: Theme.pw(0.03)
        onClicked: {
            confirmed(sliderCapacity.slider.value)
        }
    }
}
