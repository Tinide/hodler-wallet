import QtQuick 2.12
import HD.Language 1.0


Item {
    id: _agentBase

    property string name: domain
    property string status: Lang.txtRetry
    property double responseTime: 999999
    property double startPingTime: 0
    property double finishPingTime: 0
    property int reqCount: 0
    property int failCount: 0

    property string domain: ""
    property int port: 0
    property bool tls: true
    property bool canDelete: false
}
