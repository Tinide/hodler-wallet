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
    //clearStore();
    openDatabase();
    //clearSignHistory();
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

    createTables();
}

void HDStore::createTables()
{
    QSqlQuery query;
    QString sql;
    bool rc;

    sql = "CREATE TABLE if not exists address("
            "addr text primary key,"
            "label text,"
            "coinType text);";
    rc = query.exec(sql);
    if (rc == false) {
        qInfo() << query.lastError().text();
    }

    sql = "CREATE TABLE if not exists service("
              "coinType text, "
              "domain text, "
              "port integer, "
              "tls integer, "
              "auth integer, "
              "user text, "
              "pass text);";
    rc = query.exec(sql);
    if (rc == false) {
        qInfo() << query.lastError().text();
    }
    sql = "CREATE UNIQUE INDEX IF NOT EXISTS idx_service on service(domain,port);";
    rc = query.exec(sql);
    if (rc == false) {
        qInfo() << query.lastError().text();
    }

    sql = "CREATE TABLE if not exists txs("
              "txid text, "
              "dt text, "
              "coinType text, "
              "fromAddr text, "
              "toAddr text, "
              "amount text, "
              "fee text, "
              "raw text, "
              "utxoamount text, "
              "spendtx text, "
              "status integer"
              ");";
    rc = query.exec(sql);
    if (rc == false) {
        qInfo() << query.lastError().text();
    }

    sql = "CREATE UNIQUE INDEX IF NOT EXISTS idx_txid on txs(txid);";
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

