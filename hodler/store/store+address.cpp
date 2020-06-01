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


void HDStore::addAddress(QString address, uint m1, uint m2)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("insert into address(addr,m1,m2) values(:addr,:m1,:m2);");
    query.bindValue(":addr", address);
    query.bindValue(":m1", m1);
    query.bindValue(":m2", m2);
    query.exec();
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

uint HDStore::getAddressM2(QString address)
{
    //QMutexLocker locker(&_mutex);
    QSqlQuery query;
    query.prepare("select * from address where addr = :addr;");
    query.bindValue(":addr", address);
    bool rc = query.exec();
    if (rc == false) {
        qInfo() << query.lastError().text();
        return 0;
    }
    uint m2 = 0;
    query.next();
    m2 = query.record().value("m2").toUInt(&rc);
    return m2;
}
