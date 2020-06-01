/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#ifndef _KEY_H_
#define _KEY_H_

#include <QObject>
#include <QString>
#include <QByteArray>


class HDKey : public QObject
{
    Q_OBJECT
    Q_DISABLE_COPY(HDKey)
    Q_PROPERTY(QString Mac WRITE setMac NOTIFY macChanged)
    Q_PROPERTY(QString Entropy READ getEntropy WRITE setEntropy NOTIFY entropyChanged)
public:
    static HDKey *instance();

    Q_INVOKABLE QString calcMac(QString pin);
    Q_INVOKABLE bool verifyMac(QString mac);
    Q_INVOKABLE void setMac(QString mac);
    Q_INVOKABLE bool hasMac();
    Q_INVOKABLE void grantPin(QString pin);
    Q_INVOKABLE void clearGrant();
    Q_INVOKABLE bool isGranted();
    Q_INVOKABLE QString getEntropy();
    Q_INVOKABLE void setEntropy(QString entropy);
    Q_INVOKABLE bool hasEntropy();
    Q_INVOKABLE bool changePin(QString newPin);

    Q_INVOKABLE QString randomHexString(int length);
    Q_INVOKABLE void srandSeed(QString seed);

private:
    QByteArray EncryptString(QString str, QString key = "");
    QString DecryptString(QByteArray ba, QString key = "");

signals:
    void macChanged();
    void entropyChanged();

private:
    HDKey();
    virtual ~HDKey();

private:
    char *_buf{nullptr};
    QString _seed;
};

#endif //_KEY_H_
