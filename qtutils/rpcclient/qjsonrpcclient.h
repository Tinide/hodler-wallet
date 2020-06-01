/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#ifndef QJSONRPCCLIENT_H
#define QJSONRPCCLIENT_H

#include <QObject>
#include <QJsonObject>
#include <QStringList>

class QJsonRpcClient_private;


class QJsonRpcClient : public QObject
{
    Q_OBJECT
public:
    QJsonRpcClient();
    virtual ~QJsonRpcClient();

    Q_INVOKABLE void setTimeoutSec(int timeout = 30);
    Q_INVOKABLE quint64 rpcCall(QString method, QJsonObject postData, QString userData = "",
                                QString addr = "", int port = 0, bool tls = true, QString sub = "/",
                                QString user = "", QString pass = "");
    Q_INVOKABLE quint64 rpcGet(QString addr, bool tls = true, int port = 0, QString sub = "/",
                               QString userData = "", QString user = "", QString pass = "");

signals:
    void rpcReply(quint64 id, QJsonObject reply);

private:
    QJsonRpcClient_private *p;
};

#endif // QJSONRPCCLIENT_H
