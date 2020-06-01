/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#include "store.h"
#include "porter.h"
#include <QStandardPaths>
#include <QDir>
#include <QSettings>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>
#include <QSqlQueryModel>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDateTime>


void HDStore::addService(QString coinType, QString domain, int port, bool tls,
                         bool auth, QString user, QString pass)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("insert into service(coinType,domain,port,tls,auth,user,pass) "
                  "values(:coinType,:domain,:port,:tls,:auth,:user,:pass);");
    query.bindValue(":coinType", coinType);
    query.bindValue(":domain", domain);
    query.bindValue(":port", port);
    query.bindValue(":tls", tls);
    query.bindValue(":auth", auth);
    query.bindValue(":user", user);
    query.bindValue(":pass", pass);
    bool rc = query.exec();
    if (rc == false) {
        deleteService(domain, port);
        rc = query.exec();
        if (rc == false) {
            qInfo() << query.lastError().text();
        }
    }
    emit serviceAdded(coinType, domain, port, tls, auth, user, pass);
}

void HDStore::deleteService(QString domain, int port)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("delete from service where domain = :domain and port = :port;");
    query.bindValue(":domain", domain);
    query.bindValue(":port", port);
    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
    emit serviceDeleted(domain, port);
}

QString HDStore::queryService(QString coinType)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    if (coinType.isEmpty()) {
        query.prepare("select * from service;");
    } else {
        query.prepare("select * from service where coinType = :coinType;");
        query.bindValue(":coinType", coinType);
    }

    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
        return "[]";
    }

    QJsonArray array;

    while (query.next()) {
        QJsonObject obj;

        QSqlRecord record = query.record();
        QString val = record.value("coinType").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["coinType"] = val;

        val = record.value("domain").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["domain"] = val;

        int intVal = record.value("port").toInt(&rc);
        if (rc == false) {
            break;
        }
        obj["port"] = intVal;

        bool bc = record.value("tls").toBool();
        obj["tls"] = bc;
        bc = record.value("auth").toBool();
        obj["auth"] = bc;

        val = record.value("user").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["user"] = val;

        val = record.value("pass").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["pass"] = val;

        array.append(obj);
    }

    QJsonDocument doc;
    doc.setArray(array);
    QString result = doc.toJson();

    return result;
}
