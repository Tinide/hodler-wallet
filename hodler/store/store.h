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
    Q_PROPERTY(QString DefaultCoinType READ getDefaultCoinType WRITE setDefaultCoinType NOTIFY defaultCoinTypeChanged)
    Q_PROPERTY(int Language READ getLanguage WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(int Theme READ getTheme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(int QRCapacity READ getQRCapacity WRITE setQRCapacity NOTIFY qrcapacityChanged)
    Q_PROPERTY(int FontSize READ getFontSize WRITE setFontSize NOTIFY fontSizeChanged)
public:
    static HDStore *instance();
    static QString getDatabasePath();

    Q_INVOKABLE void clearStore();
    void openDatabase();

    // settings
    Q_INVOKABLE void setLanguage(int lang);
    Q_INVOKABLE int getLanguage();
    Q_INVOKABLE void setTheme(int theme);
    Q_INVOKABLE int getTheme();
    Q_INVOKABLE void setQRCapacity(int capacity);
    Q_INVOKABLE int getQRCapacity();
    Q_INVOKABLE void setAddressCount(QString coinType, int count);
    Q_INVOKABLE int getAddressCount(QString coinType);
    Q_INVOKABLE void setDefaultCoinType(QString coinType);
    Q_INVOKABLE QString getDefaultCoinType();
    Q_INVOKABLE void setFontSize(int size);
    Q_INVOKABLE int getFontSize();

    // address
    Q_INVOKABLE void addAddress(QString address, uint m1, uint m2);
    Q_INVOKABLE bool checkAddress(QString address);
    Q_INVOKABLE uint getAddressM2(QString address);

    // sign history
    Q_INVOKABLE int getSignHistoryCount(QString coinType = "", QString fromAddr = "");
    Q_INVOKABLE void appendSignHistory(QString coinType, QString datetime,
                                       QString fromAddr, QString toAddr,
                                       QString utxoamount, QString amount, QString fee, QString raw);
    Q_INVOKABLE void deleteSignRecord(int recordID);
    Q_INVOKABLE QString querySignHistory(QString coinType = "", QString fromAddr = "", int offset = 0, int limit = 200);
    Q_INVOKABLE void clearSignHistory();

signals:
    void defaultCoinTypeChanged();
    void languageChanged();
    void themeChanged();
    void qrcapacityChanged();
    void fontSizeChanged();

private:
    HDStore();
    virtual ~HDStore();
    QSqlDatabase _db;
    //QMutex _mutex;
};


#endif //_STORE_H_
