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


void HDStore::addAddress(QString address, QString label, QString coinType)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("insert into address(addr,label,coinType) values(:addr,:label,:coinType);");
    query.bindValue(":addr", address);
    query.bindValue(":label", label);
    query.bindValue(":coinType", coinType);
    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
    emit addressChanged();
}

void HDStore::deleteAddress(QString address)
{
    if (address.isEmpty()) {
        return;
    }
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("delete from address where addr = :addr;");
    query.bindValue(":addr", address);
    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
    emit addressChanged();
}

bool HDStore::checkAddress(QString address)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("select * from address where addr = :addr;");
    query.bindValue(":addr", address);
    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
    QSqlQueryModel model;
    model.setQuery(query);
    int count = model.rowCount();
    return count == 1;
}

QString HDStore::queryAddress(QString coinType)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    if (coinType.isEmpty()) {
        query.prepare("select * from address;");
    } else {
        query.prepare("select * from address where coinType = :coinType;");
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
        QString val = record.value("addr").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["addr"] = val;

        val = record.value("label").toString();
        obj["label"] = val;

        val = record.value("coinType").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["coinType"] = val;

        array.append(obj);
    }

    QJsonDocument doc;
    doc.setArray(array);
    QString result = doc.toJson();

    return result;
}

void HDStore::updateLabel(QString address, QString label)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("update address set label = :label where addr = :addr;");
    query.bindValue(":label", label);
    query.bindValue(":addr", address);
    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
}
