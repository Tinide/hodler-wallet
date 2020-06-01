/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#include "store.h"
#include "hodler.h"
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


int HDStore::getSignHistoryCount(QString coinType, QString fromAddr)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    if (fromAddr.isEmpty()) {
        if (coinType.isEmpty()) {
            query.prepare("select id from signhistory;");
        } else {
            query.prepare("select id from signhistory where coinType = :coinType;");
            query.bindValue(":coinType", coinType);
        }
    } else {
        query.prepare("select * from signhistory where coinType = :coinType and fromAddr = :fromAddr ;");
        query.bindValue(":coinType", coinType);
        query.bindValue(":fromAddr", fromAddr);
    }

    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
    QSqlQueryModel model;
    model.setQuery(query);
    int count = model.rowCount();
//    QSqlRecord record = query.record();
//    int count = record.value(0).toInt(&rc);
//    if (rc == false) {
//        qInfo() << query.lastError().text();
//    }

    return count;
}

void HDStore::appendSignHistory(QString coinType, QString datetime,
                                QString fromAddr, QString toAddr,
                                QString utxoamount, QString amount, QString fee, QString raw)
{
    if (datetime.isEmpty()) {
        QDateTime dt = QDateTime::currentDateTime();
        datetime = dt.toString("yyyy-MM-dd HH:mm:ss");
    }

    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("insert into signhistory(coinType,dt,fromAddr,toAddr,utxoamount,amount,fee,raw) "
                                                 "values(:coinType,"
                                                 ":datetTime,"
                                                 ":fromAddr,"
                                                 ":toAddr,"
                                                 ":utxoamount,"
                                                 ":amount,"
                                                 ":fee,"
                                                 ":raw"
                                                 ");");
    query.bindValue(":coinType", coinType);
    query.bindValue(":datetTime", datetime);
    query.bindValue(":fromAddr", fromAddr);
    query.bindValue(":toAddr", toAddr);
    query.bindValue(":utxoamount", utxoamount);
    query.bindValue(":amount", amount);
    query.bindValue(":fee", fee);
    query.bindValue(":raw", raw);

    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
}

void HDStore::deleteSignRecord(int recordID)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("delete from signhistory where id = :recordID;");
    query.bindValue(":recordID", recordID);
    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
}

QString HDStore::querySignHistory(QString coinType, QString fromAddr, int offset, int limit)
{
    int total = getSignHistoryCount(coinType, fromAddr);
    if (total > limit) {
        offset = ((total / limit) * limit) - limit + (total % limit);
    }
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    if (fromAddr.isEmpty()) {
        if (coinType.isEmpty()) {
            query.prepare("select * from signhistory "
                          "limit :limit offset :offset;");
        } else {
            query.prepare("select * from signhistory "
                          "where coinType = :coinType "
                          "limit :limit offset :offset;");
            query.bindValue(":coinType", coinType);
        }
    } else {
        query.prepare("select * from signhistory "
                      "where coinType = :coinType and fromAddr = :fromAddr "
                      "limit :limit offset :offset;");
        query.bindValue(":coinType", coinType);
        query.bindValue(":fromAddr", fromAddr);
    }
    query.bindValue(":limit", limit);
    query.bindValue(":offset", offset);

    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
        return "[]";
    }

    QJsonArray array;

    while (query.next()) {
        QJsonObject obj;

        QSqlRecord record = query.record();
        QString val = record.value("id").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["recid"] = val;

        val = record.value("coinType").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["coinType"] = val;

        val = record.value("dt").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["datetime"] = val;

        val = record.value("fromAddr").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["fromAddr"] = val;

        val = record.value("toAddr").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["toAddr"] = val;

        val = record.value("utxoamount").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["utxoamount"] = val;

        val = record.value("amount").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["amount"] = val;

        val = record.value("fee").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["fee"] = val;

        val = record.value("raw").toString();
        if (rc == false || val.isEmpty()) {
            break;
        }
        obj["raw"] = val;

        array.append(obj);
    }

    QJsonDocument doc;
    doc.setArray(array);
    QString result = doc.toJson();

    return result;
}

void HDStore::clearSignHistory()
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.exec("DELETE FROM signhistory;");
}
