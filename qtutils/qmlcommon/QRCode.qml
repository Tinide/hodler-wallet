import QtQuick 2.12
import QtQuick.Controls 2.12
import Theme 1.0
import QRCode 1.0


Rectangle {
    id: _rectBackground
    width: parent.width < parent.height ? parent.width * 0.9 : parent.height * 0.65
    height: width
    color: "#ffffff"

    property alias qrdata: qrItem.qrData

    QRItem {
        id: qrItem
        width: parent.width * 0.94
        height: width
        anchors.centerIn: parent
        qrData: ""
    }
}

