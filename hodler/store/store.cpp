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


HDStore *_hdstore_ = nullptr;


HDStore *HDStore::instance()
{
    if (_hdstore_ == nullptr) {
        _hdstore_ = new HDStore;
    }
    return _hdstore_;
}

HDStore::HDStore() : QObject(nullptr)
{
    openDatabase();
}

HDStore::~HDStore()
{
}

QString HDStore::getDatabasePath()
{
    QString path;
    QStringList pathList = QStandardPaths::standardLocations(QStandardPaths::DataLocation);
    foreach (QString p, pathList) {
        if (p.compare("/") != 0 && p.compare("") != 0) {
            path = p;
            break;
        }
    }
    if (path.isEmpty()) {
#ifdef Q_OS_ANDROID
        path = "/sdcard";
#endif
    }
    path += "/";
    path += SETS_APP;
    QDir dir;
    dir.mkpath(path);
    return path;
}

void HDStore::openDatabase()
{
    //QMutexLocker locker(&_mutex);
    QString storePath = getDatabasePath();
    QString dbFile = storePath + "/" SETS_APP ".db";
    _db = QSqlDatabase::addDatabase("QSQLITE");
    _db.setDatabaseName(dbFile);
    bool rc = _db.open();
    if (rc == false) {
        qInfo() << "database open false:" << dbFile;
        return;
    }

    QString sql = "CREATE TABLE if not exists signhistory("
                  "id integer PRIMARY KEY AUTOINCREMENT, "
                  "coinType text, "
                  "dt text, "
                  "fromAddr text, "
                  "toAddr text, "
                  "utxoamount text, "
                  "amount text, "
                  "fee text, "
                  "raw text);";
    QSqlQuery query;
    rc = query.exec(sql);
    if (rc == false) {
        qInfo() << query.lastError().text();
    }

//    sql = "CREATE UNIQUE INDEX IF NOT EXISTS idx_rawtx on signhistory(coinType,raw);";
//    rc = query.exec(sql);
//    if (rc == false) {
//        qInfo() << query.lastError().text();
//    }

    sql = "CREATE TABLE if not exists address(addr text PRIMARY KEY, m1 integer, m2 integer);";
    rc = query.exec(sql);
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
}

void HDStore::clearStore()
{
    //_mutex.lock();
    _db.close();
    QString storePath = getDatabasePath();
    QString dbFile = storePath + "/" SETS_APP ".db";
    QFile::remove(dbFile);
    //_mutex.unlock();

    openDatabase();

    QSettings sets(SETS_ORG, SETS_APP);
    sets.clear();
}
