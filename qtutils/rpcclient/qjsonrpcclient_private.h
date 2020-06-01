/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#ifndef QJSONRPCCLIENT_PRIVATE_H
#define QJSONRPCCLIENT_PRIVATE_H

#include <QObject>
#include <QJsonObject>
#include <QStringList>
#include <QJsonArray>
#include <QNetworkAccessManager>
#include <QNetworkReply>
#include <QList>
#include <QSslError>
#include <QUrl>
#include <QMutex>


class QJsonRpcClient;

#define REPLY_ROLE_ID     (Qt::UserRole + 1)
#define REPLY_ROLE_URL    (Qt::UserRole + 2)
#define REPLY_ROLE_UDATA  (Qt::UserRole + 3)
#define REPLY_ROLE_TIMER  (Qt::UserRole + 4)
#define REPLY_ROLE_USER   (Qt::UserRole + 5)
#define REPLY_ROLE_PASS   (Qt::UserRole + 6)
#define REPLY_ROLE_STATUS (Qt::UserRole + 7)
#define REPLY_ROLE_BUF    (Qt::UserRole + 100)


class QJsonRpcClient_private : public QObject
{
    Q_OBJECT
    friend class QJsonRpcClient;
private:
    QJsonRpcClient_private();

    void setTimeoutSec(int timeout);
    quint64 rpcCall(QString method, QJsonObject postData, QString userData,
                    QString addr, int port, bool tls, QString sub,
                    QString user, QString pass);
    QJsonObject BuildRpcRequest(QString method, QJsonObject data, quint64 requestID);
    void SetReplyUserdata(QNetworkReply *reply, QString url, quint64 requestID, QString userData,
                          QString user, QString pass);
    void ReleaseReply(QNetworkReply *reply);
    quint64 NewRequestID();

signals:
    void rpcReply(quint64 id, QJsonObject reply);

public slots:
    void authenticationRequired(QNetworkReply *reply, QAuthenticator *authenticator);
    void sslErrors(QNetworkReply *, const QList<QSslError> &errors);
    void httpFinished();
    void httpReadyRead();
    void error(QNetworkReply::NetworkError);

private:
    QNetworkAccessManager _network;
    quint64 _replyID{0};
    QMutex _mutex;
    int _timeout{30};
};

#endif // QJSONRPCCLIENT_PRIVATE_H
