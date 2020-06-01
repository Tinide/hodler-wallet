/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#ifndef _STORE_H_
#define _STORE_H_

#include <QObject>
#include <QString>
#include <QSqlDatabase>
#include <QMutex>
#include <QMutexLocker>


class HDStore : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(HDStore)
    Q_PROPERTY(int Language READ getLanguage WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(int Theme READ getTheme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(int QRCapacity READ getQRCapacity WRITE setQRCapacity NOTIFY qrcapacityChanged)
    Q_PROPERTY(int FontSize READ getFontSize WRITE setFontSize NOTIFY fontSizeChanged)
public:
    static HDStore *instance();
    static QString getDatabasePath();

    Q_INVOKABLE void clearStore();

    // address
    Q_INVOKABLE void addAddress(QString address, QString label, QString coinType);
    Q_INVOKABLE void deleteAddress(QString address);
    Q_INVOKABLE bool checkAddress(QString address);
    Q_INVOKABLE QString queryAddress(QString coinType = "");
    Q_INVOKABLE void updateLabel(QString address, QString label);

    // service
    Q_INVOKABLE void addService(QString coinType, QString domain, int port,
                                bool tls = true, bool auth = false,
                                QString user = "", QString pass = "");
    Q_INVOKABLE void deleteService(QString domain, int port);
    Q_INVOKABLE QString queryService(QString coinType);

    // settings
    Q_INVOKABLE void setLanguage(int lang);
    Q_INVOKABLE int getLanguage();
    Q_INVOKABLE void setTheme(int theme);
    Q_INVOKABLE int getTheme();
    Q_INVOKABLE void setQRCapacity(int capacity);
    Q_INVOKABLE int getQRCapacity();
    Q_INVOKABLE void setFontSize(int size);
    Q_INVOKABLE int getFontSize();

    // transactions
    Q_INVOKABLE void appendTxRecord(QString txid, QString coinType,
                                    QString fromAddr, QString toAddr,
                                    QString amount, QString fee, QString raw,
                                    QString utxoamount = "0", QString spendtxs = "0");
    Q_INVOKABLE void deleteTxRecord(QString txid);
    Q_INVOKABLE int getTxCount(QString coinType = "", QString fromAddr = "");
    Q_INVOKABLE QString queryTxRecord(QString coinType = "", QString addr = "", bool fromAddr = true,
                                      int offset = 0, int limit = 1000);
    Q_INVOKABLE void clearSignHistory();
    // status  -1:unconfirmed  -2:bad  -3:deleted
    Q_INVOKABLE void updateTxRecord(QString txid, int status);

signals:
    void languageChanged();
    void themeChanged();
    void qrcapacityChanged();
    void addressChanged();
    void fontSizeChanged();
    void serviceAdded(QString coinType, QString domain, int port, bool tls, bool auth, QString user, QString pass);
    void serviceDeleted(QString domain, int port);
    void txAdded(QString record);

private:
    HDStore();
    virtual ~HDStore();
    void openDatabase();
    void createTables();

    QSqlDatabase _db;
    //QMutex _mutex;
};


#endif //_STORE_H_
