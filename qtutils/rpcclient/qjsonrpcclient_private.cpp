/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#include "qjsonrpcclient_private.h"
#include <QJsonDocument>
#include <QJsonArray>
#include <QByteArray>
#include <QTimer>
#include <QAuthenticator>
#include <QDebug>


QJsonRpcClient_private::QJsonRpcClient_private()
    : QObject ()
{
    connect(&_network, &QNetworkAccessManager::sslErrors,
            this, &QJsonRpcClient_private::sslErrors);
    connect(&_network, &QNetworkAccessManager::authenticationRequired,
            this, &QJsonRpcClient_private::authenticationRequired);
}

void QJsonRpcClient_private::setTimeoutSec(int timeout)
{
    _timeout = timeout;
    if (_timeout < 3) {
        _timeout = 3;
    }
}

QJsonObject QJsonRpcClient_private::BuildRpcRequest(QString method, QJsonObject data, quint64 requestID)
{
    QJsonObject req;
    req["method"] = method;
    req["id"] = static_cast<qint64>(requestID);

    QJsonArray array = data["params"].toArray();
    req["params"] = array;
    req["jsonrpc"] = "1.0";
    //qInfo() << req;

    return req;
}

quint64 QJsonRpcClient_private::rpcCall(QString method, QJsonObject postData, QString userData,
                                        QString addr, int port, bool tls, QString sub,
                                        QString user, QString pass)
{
    QUrl url;
    QString strUrl;
    if (tls) {
        strUrl = "https://";
    }
    else {
        strUrl = "http://";
    }
    if (port > 0) {
        strUrl += addr + ":" + QString::number(port) + sub;
    } else {
        strUrl += addr + sub;
    }
    url.setUrl(strUrl);

    //qInfo() << strUrl;

    QNetworkRequest req(url);
    req.setAttribute(QNetworkRequest::CacheLoadControlAttribute, QNetworkRequest::AlwaysNetwork);
    req.setHeader(QNetworkRequest::ContentTypeHeader, "application/json");
    req.setRawHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:75.0) Gecko/20100101 Firefox/75.0");
    req.setRawHeader("Accept", "application/json, text/plain, */*");
    req.setRawHeader("Accept-Encoding", "deflate");
    req.setRawHeader("Cache-Control", "max-age=0");
    if (user.isEmpty() == false && pass.isEmpty() == false) {
        QString token = user + ":" + pass;
        token = "Basic " + token.toUtf8().toBase64();
        req.setRawHeader("Authorization", token.toUtf8());
    }

    quint64 rid = NewRequestID();
    QNetworkReply *reply;

    if (postData.isEmpty()) {
        reply = _network.get(req);
    } else {
        if (postData["rawpost"].isString()) {
            if (postData["Content-Type"].isString()) {
                req.setRawHeader("Content-Type", postData["Content-Type"].toString().toUtf8());
            }
            if (postData["Accept"].isString()) {
                req.setRawHeader("Accept", postData["Accept"].toString().toUtf8());
            }
            QString rawpost = postData["rawpost"].toString();
            reply = _network.post(req, rawpost.toUtf8());
        } else {
            QJsonObject rpcReq = BuildRpcRequest(method, postData, rid);
            QJsonDocument doc(rpcReq);
            QByteArray data = doc.toJson(QJsonDocument::Compact);
            reply = _network.post(req, data);
        }
    }
    SetReplyUserdata(reply, strUrl, rid, userData, user, pass);
    connect(reply, &QNetworkReply::finished, this, &QJsonRpcClient_private::httpFinished);
    connect(reply, &QIODevice::readyRead, this, &QJsonRpcClient_private::httpReadyRead);
    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(error(QNetworkReply::NetworkError)));

    return rid;
}

void QJsonRpcClient_private::SetReplyUserdata(QNetworkReply *reply, QString url, quint64 requestID, QString userData,
                                              QString user, QString pass)
{
    QString *pID = new QString(QString::number(requestID));
    QString *pUrl = new QString(url);
    QString *pData = new QString(userData);
    QString *pStatus = new QString("0");
    QTimer *timer = new QTimer();
    QString *pUser = new QString(user);
    QString *pPass = new QString(pass);
    QByteArray *pBuf = new QByteArray;

    timer->setInterval(_timeout * 1000);
    timer->setSingleShot(true);
    connect(timer, SIGNAL(timeout()), reply, SIGNAL(finished()));

    reply->setUserData(REPLY_ROLE_ID, (QObjectUserData*)pID);
    reply->setUserData(REPLY_ROLE_URL, (QObjectUserData*)pUrl);
    reply->setUserData(REPLY_ROLE_UDATA, (QObjectUserData*)pData);
    reply->setUserData(REPLY_ROLE_TIMER, (QObjectUserData*)timer);
    reply->setUserData(REPLY_ROLE_BUF, (QObjectUserData*)pBuf);
    reply->setUserData(REPLY_ROLE_STATUS, (QObjectUserData*)pStatus);
    reply->setUserData(REPLY_ROLE_USER, (QObjectUserData*)pUser);
    reply->setUserData(REPLY_ROLE_PASS, (QObjectUserData*)pPass);

    timer->start();
}

void QJsonRpcClient_private::ReleaseReply(QNetworkReply *reply)
{
    QString *pID = (QString*)reply->userData(REPLY_ROLE_ID);
    QString *pUrl = (QString*)reply->userData(REPLY_ROLE_URL);
    QString *pData = (QString*)reply->userData(REPLY_ROLE_UDATA);
    QTimer *timer = (QTimer*)reply->userData(REPLY_ROLE_TIMER);
    QString *pUser = (QString*)reply->userData(REPLY_ROLE_USER);
    QString *pPass = (QString*)reply->userData(REPLY_ROLE_PASS);
    QByteArray *pBuf = (QByteArray*)reply->userData(REPLY_ROLE_BUF);
    QString *pStatus = (QString*)reply->userData(REPLY_ROLE_STATUS);

    reply->setUserData(REPLY_ROLE_ID, NULL);
    reply->setUserData(REPLY_ROLE_URL, NULL);
    reply->setUserData(REPLY_ROLE_UDATA, NULL);
    reply->setUserData(REPLY_ROLE_TIMER, NULL);
    reply->setUserData(REPLY_ROLE_USER, NULL);
    reply->setUserData(REPLY_ROLE_PASS, NULL);
    reply->setUserData(REPLY_ROLE_BUF, NULL);
    reply->setUserData(REPLY_ROLE_STATUS, NULL);

    delete pID;
    delete pUrl;
    delete pData;
    delete timer;
    delete pUser;
    delete pPass;
    delete pBuf;
    delete pStatus;

    reply->deleteLater();
}

quint64 QJsonRpcClient_private::NewRequestID()
{
    quint64 rid;
    _mutex.lock();
    rid = _replyID++;
    _mutex.unlock();
    return rid;
}

void QJsonRpcClient_private::error(QNetworkReply::NetworkError)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    QString *pUrl = (QString*)reply->userData(REPLY_ROLE_URL);
    if (pUrl) {
        qInfo() << *pUrl << ", reply error";
    }
    QString *pStatus = (QString*)reply->userData(REPLY_ROLE_STATUS);
    if (pStatus) {
        *pStatus = "1";
    }
//    _network.clearAccessCache();
//    _network.clearConnectionCache();
}

void QJsonRpcClient_private::httpFinished()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    QString *pID = (QString*)reply->userData(REPLY_ROLE_ID);
    QString *pUrl = (QString*)reply->userData(REPLY_ROLE_URL);
    if (!pID || !pUrl) {
        qInfo() << "incorrect reply";
        return;
    }
    quint64 rid = pID->toULongLong();

    QByteArray result = reply->readAll();
    QByteArray *pBuf = (QByteArray*)reply->userData(REPLY_ROLE_BUF);
    if (pBuf) {
        if (!result.isEmpty()) {
            pBuf->append(result);
        }
        result = *pBuf;
    }
    if (result.isEmpty()) {
        qInfo() << *pUrl << ", read empty, connection reset";
//        _network.clearAccessCache();
//        _network.clearConnectionCache();
    }
    //qInfo() << result;

    QJsonDocument doc = QJsonDocument::fromJson(result);
    QJsonObject json = doc.object();
    if (json.isEmpty()) {
        QJsonArray array = doc.array();
        if (array.isEmpty()) {
            json["response.text"] = QString(result);
        } else {
            json["array"] = array;
        }
    }
    QString *pData = (QString*)reply->userData(REPLY_ROLE_UDATA);
    if (pData) {
        json["user_data"] = *pData;
    }
    QString *pStatus = (QString*)reply->userData(REPLY_ROLE_STATUS);
    if (pStatus) {
        json["response.status"] = (*pStatus).toInt();
    }
    emit rpcReply(rid, json);

    ReleaseReply(reply);
}

void QJsonRpcClient_private::httpReadyRead()
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    QByteArray *pBuf = (QByteArray*)reply->userData(REPLY_ROLE_BUF);
    if (!pBuf) {
        return;
    }
    QByteArray result = reply->readAll();
    pBuf->append(result);
}

void QJsonRpcClient_private::sslErrors(QNetworkReply *reply, const QList<QSslError> &e)
{
    reply->ignoreSslErrors();
}

void QJsonRpcClient_private::authenticationRequired(QNetworkReply *reply, QAuthenticator *authenticator)
{
    QString *pUser = (QString*)reply->userData(REPLY_ROLE_USER);
    QString *pPass = (QString*)reply->userData(REPLY_ROLE_PASS);
    if (pUser && pPass) {
        authenticator->setUser(*pUser);
        authenticator->setPassword(*pPass);
    }
}
