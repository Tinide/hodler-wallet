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


void HDStore::appendTxRecord(QString txid, QString coinType,
                             QString fromAddr, QString toAddr,
                             QString amount, QString fee, QString raw,
                             QString utxoamount, QString spendtxs)
{
    //QMutexLocker locker(&_mutex);
    QDateTime dt = QDateTime::currentDateTime();
    QString datetime = dt.toString("yyyy-MM-dd HH:mm:ss");

    {
        QSqlQuery query;
        query.prepare("select * from txs where txid = :txid;");
        query.bindValue(":txid", txid);
        bool rc = query.exec();
        if (rc == false) {
            qInfo() << query.lastError().text();
            return;
        }
        QSqlQueryModel model;
        model.setQuery(query);
        int count = model.rowCount();
        if (count > 0) {
            return;
        }
    }

    QSqlQuery query;
    query.prepare("insert into txs(txid,dt,coinType,fromAddr,toAddr,amount,fee,raw,utxoamount,spendtx,status) "
                                  "values("
                                  ":txid,"
                                  ":datetTime,"
                                  ":coinType,"
                                  ":fromAddr,"
                                  ":toAddr,"
                                  ":amount,"
                                  ":fee,"
                                  ":raw,"
                                  ":utxoamount,"
                                  ":spendtx,"
                                  ":status"
                                  ");");
    query.bindValue(":txid", txid);
    query.bindValue(":datetTime", datetime);
    query.bindValue(":coinType", coinType);
    query.bindValue(":fromAddr", fromAddr);
    query.bindValue(":toAddr", toAddr);
    query.bindValue(":amount", amount);
    query.bindValue(":fee", fee);
    query.bindValue(":raw", raw);
    query.bindValue(":utxoamount", utxoamount);
    query.bindValue(":spendtx", spendtxs);
    query.bindValue(":status", -1);

    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
        return;
    }

    QJsonObject obj;
    obj["txid"] = txid;
    obj["coinType"] = coinType;
    obj["datetime"] = datetime;
    obj["fromAddr"] = fromAddr;
    obj["toAddr"] = toAddr;
    obj["amount"] = amount;
    obj["fee"] = fee;
    obj["raw"] = raw;
    obj["utxoamount"] = utxoamount;
    obj["spendtxs"] = spendtxs;
    obj["status"] = -1;
    QJsonDocument doc(obj);
    QString strItem = doc.toJson();
    emit txAdded(strItem);
}

void HDStore::deleteTxRecord(QString txid)
{
    if (txid.isEmpty()) {
        return;
    }
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("delete from txs where txid = :txid;");
    query.bindValue(":txid", txid);
    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
}

int HDStore::getTxCount(QString coinType, QString fromAddr)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    if (fromAddr.isEmpty()) {
        if (coinType.isEmpty()) {
            query.prepare("select coinType from txs;");
        } else {
            query.prepare("select coinType from txs where coinType = :coinType;");
            query.bindValue(":coinType", coinType);
        }
    } else {
        query.prepare("select coinType from txs where coinType = :coinType and fromAddr = :fromAddr ;");
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
    return count;
}

QString HDStore::queryTxRecord(QString coinType, QString addr, bool fromAddr, int offset, int limit)
{
    int total;
    if (fromAddr) {
        total = getTxCount(coinType, addr);
    } else {
        total = getTxCount(coinType, "");
    }
    if (total > limit) {
        offset = ((total / limit) * limit) - limit + (total % limit);
    }

    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    if (addr.isEmpty()) {
        if (coinType.isEmpty()) {
            query.prepare("select * from txs "
                          "limit :limit offset :offset;");
        } else {
            query.prepare("select * from txs "
                          "where coinType = :coinType "
                          "limit :limit offset :offset;");
            query.bindValue(":coinType", coinType);
        }
    } else {
        if (fromAddr) {
            query.prepare("select * from txs "
                          "where coinType = :coinType and fromAddr = :fromAddr "
                          "limit :limit offset :offset;");
            query.bindValue(":coinType", coinType);
            query.bindValue(":fromAddr", addr);
        } else {
            query.prepare("select * from txs "
                          "where coinType = :coinType and toAddr = :toAddr "
                          "limit :limit offset :offset;");
            query.bindValue(":coinType", coinType);
            query.bindValue(":toAddr", addr);
        }
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
        QString val = record.value("txid").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["txid"] = val;

        val = record.value("coinType").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["coinType"] = val;

        val = record.value("dt").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["datetime"] = val;

        val = record.value("fromAddr").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["fromAddr"] = val;

        val = record.value("toAddr").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["toAddr"] = val;

        val = record.value("amount").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["amount"] = val;

        val = record.value("fee").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["fee"] = val;

        val = record.value("raw").toString();
        if (val.isEmpty()) {
            break;
        }
        obj["raw"] = val;

        val = record.value("utxoamount").toString();
        if (val.isEmpty()) {
            obj["utxoamount"] = "";
        } else {
            obj["utxoamount"] = val;
        }

        val = record.value("spendtx").toString();
        if (val.isEmpty()) {
            obj["spendtx"] = "";
        } else {
            obj["spendtx"] = val;
        }

        int ss = record.value("status").toInt(&rc);
        if (rc == false) {
            break;
        }
        obj["status"] = ss;

        array.append(obj);
    }

    QJsonDocument doc;
    doc.setArray(array);
    QString result = doc.toJson();

    return result;
}

void HDStore::clearSignHistory()
{
    QSqlQuery query;
    query.exec("delete from txs;");
}

void HDStore::updateTxRecord(QString txid, int status)
{
    QSqlQuery query;
    query.prepare("update txs set status = :status where txid = :txid;");
    query.bindValue(":status", status);
    query.bindValue(":txid", txid);
    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
}
