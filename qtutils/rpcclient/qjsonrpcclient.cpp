/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#include "qjsonrpcclient.h"
#include "qjsonrpcclient_private.h"


QJsonRpcClient::QJsonRpcClient() : QObject ()
{
    p = new QJsonRpcClient_private();
    connect(p, SIGNAL(rpcReply(quint64,QJsonObject)), this, SIGNAL(rpcReply(quint64,QJsonObject)));
}

QJsonRpcClient::~QJsonRpcClient()
{
    delete p;
}

void QJsonRpcClient::setTimeoutSec(int timeout)
{
    p->setTimeoutSec(timeout);
}

quint64 QJsonRpcClient::rpcCall(QString method, QJsonObject postData, QString userData,
                                QString addr, int port, bool tls, QString sub,
                                QString user, QString pass)
{
    return p->rpcCall(method, postData, userData, addr, port, tls, sub, user, pass);
}

quint64 QJsonRpcClient::rpcGet(QString addr, bool tls, int port, QString sub,
                               QString userData, QString user, QString pass)
{
    QJsonObject obj;
    return p->rpcCall("", obj, userData, addr, port, tls, sub, user, pass);
}
