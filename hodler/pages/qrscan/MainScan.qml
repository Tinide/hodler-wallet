import QtQuick 2.12
import QtQuick.Controls 2.12
import QtMultimedia 5.12
import HD.Language 1.0
import HD.JsonRpc 1.0
import HD.Config 1.0
import HD.Key 1.0
import Theme 1.0
import "qrc:/common"


Rectangle {
    id: _pageScan
    anchors.fill: parent
    color: Theme.darkColor6
    visible: false
    opacity: 0

    property bool active: false
    property int curPage: 0
    property int maxPage: 0
    property string coinType: ""
    property string fromAddr: ""
    property string toAddr: ""
    property string amount: ""
    property string raw: ""
    property var callback: null

    signal backClicked()

    function start() {
        barTitle.textTitle = Lang.txtQRScan
        curPage = 0
        maxPage = 0
        coinType = ""
        fromAddr = ""
        toAddr = ""
        amount = "0"
        raw = ""

        active = true
        visible = true
        opacity = 1

        loaderScanner.source = "qrc:/common/QRScanner.qml"
        loaderScanner.active = true
    }

    function stop() {
        opacity = 0
        actionFadeout.running = true
        active = false
        loaderScanner.active = false
        loaderScanner.source = ""
    }

    function callBackScan(cb) {
        callback = cb
        Config.hideHomeBar()
        _pageScan.start()
    }

    Connections {
        target: Theme
        onQrScanResult: {
            sndBarcode.play()
            if (callback != null) {
                callback(qrd)
                callback = null
                _pageScan.backClicked()
                return
            }
            try {
                var json = JSON.parse(qrd)
                if (json["s"] !== "HODL") {throw Lang.msgUnknownQRData}
                if (json["m"] !== "TX") {throw Lang.msgUnknownQRData}
                var cp = json["c"] // current page
                var mp = json["p"] // total pages
                if (cp === 0 || mp === 0) {throw Lang.msgUnknownQRData}
                if (cp - curPage > 1) {throw Lang.msgBadQRDataPageNum}
                if (curPage === cp) {return}
                curPage = cp
                var ct = json["t"] // token type
                var fa = json["f"] // from address
                var ta = json["o"] // to address
                var am = json["a"] // amount
                var rw = json["d"] // rawtx
                if (curPage == 1) {
                    maxPage = mp
                    coinType = ct
                    fromAddr = fa
                    toAddr = ta
                    amount = am
                    raw = rw
                    if (curPage != maxPage) {
                        //Theme.showToast(Lang.msgShowNextQRPage)
                    }
                } else if (   coinType !== ct
                           || fromAddr !== fa
                           || toAddr !== ta
                           || maxPage !== mp) {
                    throw Lang.msgUnknownQRData
                } else {
                    raw += rw
                }
                if (curPage === maxPage) {
                    json["d"] = raw
                    var qrdata = JSON.stringify(json)
                    var rc = pageScanResult.loadJsonData(qrdata)
                    if (rc === true) {
                        pageScanResult.show()
                        loaderScanner.active = false
                        loaderScanner.source = ""
                    } else {
                        Theme.showToast(Lang.msgUnknownQRData)
                    }
                }
                barTitle.textTitle = Lang.txtQRScan + "  (" + Lang.txtPage + ": " + curPage + " / " + maxPage + ")"
            } catch (e) {
                Theme.showToast(e)
                return
            }
        }
    }

    Behavior on opacity {
        PropertyAnimation{
            easing.type: Easing.InOutQuad
            duration: 400
        }
    }

    SequentialAnimation {
        id: actionFadeout
        running: false

        PauseAnimation { duration: 388 }
        PropertyAction {
            target: _pageScan
            property: "visible"
            value: false
        }
    }

    MouseArea { anchors.fill: parent }

    QTitleBar {
        id: barTitle
        textTitle: Lang.txtQRScan
        textLeft: Lang.txtBack
        curVal: curPage
        maxVal: maxPage
        onLeftClicked: {
            backClicked()
        }
    }

    Loader {
        id: loaderScanner
        active: false
        width: Theme.pw(1)
        anchors.top: barTitle.bottom
        anchors.bottom: parent.bottom
    }

    ScanResult {
        id: pageScanResult
        anchors.fill: parent
        onBackClicked: {
            pageScanResult.hide()
            _pageScan.backClicked()
        }
    }

    MediaPlayer {
        id: sndBarcode
        volume: 0.04
        source: "qrc:/media/beep.mp3"
    }
}
