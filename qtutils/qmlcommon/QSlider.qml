import QtQuick 2.12
import QtQuick.Controls 1.4
import QtQuick.Controls.Styles 1.4
import Theme 1.0


Item {
    id: _item
    width: 600
    height: 20

    property alias slider: _slider

    Slider {
        id: _slider
        anchors.fill: parent
        minimumValue: 0
        maximumValue: 100
        value: 50
        stepSize: 1

        style: SliderStyle {
            handle: Rectangle {
                anchors.centerIn: parent
                color: Theme.darkColor1
                width: _item.height * 0.8
                height: width
                radius: width * 0.5

                Rectangle {
                    anchors.centerIn: parent
                    color: Theme.darkColor2
                    width: parent.width * 2.5
                    height: width
                    radius: width * 0.5
                    opacity: 0.3
                    visible: control.pressed
                }
            }
            groove: Rectangle {
                implicitHeight: _item.height * 0.25
                color: Theme.darkColor4
                radius: _item.height * 0.1

                Rectangle {
                    implicitHeight: _item.height * 0.25
                    color: Theme.darkColor1
                    radius: _item.height * 0.1
                    anchors.left: parent.left
                    width: {
                        var d = _slider.maximumValue - _slider.minimumValue
                        var r = (_slider.value - _slider.minimumValue) / d
                        return parent.width * r
                    }
                }
            }
        }
    }
}

