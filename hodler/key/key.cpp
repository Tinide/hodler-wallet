/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#include "key.h"
#include <QCryptographicHash>
#include <QSettings>
#include <QVariant>
#include <QDebug>
#include <QDateTime>
#include "hodler.h"
#include "qaesencryption.h"


HDKey *_hdkey_ = nullptr;


HDKey *HDKey::instance()
{
    if (_hdkey_ == nullptr) {
        _hdkey_ = new HDKey;
    }
    return _hdkey_;
}

HDKey::HDKey() : QObject(nullptr)
{
#if 0 // clear
    QSettings sets(SETS_ORG, SETS_APP);
    sets.clear();
#endif
}

HDKey::~HDKey()
{
}

QString HDKey::calcMac(QString pin)
{
    QByteArray byteArray;
    byteArray.append(pin);
    QByteArray hash = QCryptographicHash::hash(byteArray, QCryptographicHash::Sha256);
    hash = QCryptographicHash::hash(hash, QCryptographicHash::Sha256);
    QString mac = hash.toHex();
    // clear stack
    pin.fill('\0');
    return mac.toUpper();
}

bool HDKey::verifyMac(QString mac)
{
    QSettings sets(SETS_ORG, SETS_APP);
    QVariant v = sets.value("mac");
    QByteArray ba = v.toByteArray();
    QString decodedString = DecryptString(ba);
    bool rc = mac == decodedString;
    mac.fill('\0');
    decodedString.fill('\0');
    return rc;
}

void HDKey::setMac(QString mac)
{
    QSettings setsAddr(SETS_ORG, SETS_APP SETS_ADDR_COUNT);
    setsAddr.clear();

    QSettings sets(SETS_ORG, SETS_APP);
    if (mac.isEmpty()) {
        sets.setValue("mac", "");
        sets.setValue("entropy", "");
        clearGrant();
        return;
    }
    QByteArray ba = EncryptString(mac);
    sets.setValue("mac", ba);
    mac.fill('\0');
}

bool HDKey::hasMac()
{
    QSettings sets(SETS_ORG, SETS_APP);
    QVariant v = sets.value("mac");
    QByteArray mac = v.toByteArray();
    return !mac.isEmpty();
}

void HDKey::grantPin(QString pin)
{
    if (_buf) clearGrant();
    QByteArray ba = EncryptString(pin + SETS_ORG SETS_APP, pin).toHex();
    ba = QCryptographicHash::hash(ba, QCryptographicHash::Sha256).toHex();
    ba = QCryptographicHash::hash(ba, QCryptographicHash::Sha256).toHex();
    _buf = (char*)malloc(512);
    if (_buf == NULL) return;
    memset(_buf, 0, 512);
    memcpy(_buf, ba.constData(), ba.length());
    ba.fill('\0');
    pin.fill('\0');
}

void HDKey::clearGrant()
{
    if (_buf) {
        memset(_buf, 0, 512);
        free(_buf);
        _buf = NULL;
    }
}

bool HDKey::isGranted()
{
    return !(_buf == NULL);
}

QString HDKey::getEntropy()
{
    if (isGranted() == false) {
        return "";
    }
    QSettings sets(SETS_ORG, SETS_APP);
    QVariant v = sets.value("entropy");
    QByteArray ba = v.toByteArray();
    if (ba.isEmpty()) {
        return "";
    }
    QString decodedString = DecryptString(ba, _buf);
    return decodedString;
}

void HDKey::setEntropy(QString entropy)
{
    if (isGranted() == false) {
        return;
    }
    QSettings sets(SETS_ORG, SETS_APP);
    QByteArray ba = EncryptString(entropy, _buf);
    sets.setValue("entropy", ba);
    entropy.fill('\0');
}

bool HDKey::hasEntropy()
{
    QSettings sets(SETS_ORG, SETS_APP);
    QVariant v = sets.value("entropy");
    QByteArray ent = v.toByteArray();
    return !ent.isEmpty();
}

bool HDKey::changePin(QString newPin)
{
    if (newPin.isEmpty()) {
        return false;
    }
    if (hasMac() == false) {
        return false;
    }
    if (isGranted() == false) {
        return false;
    }
    QString entropy = getEntropy();
    QString mac = calcMac(newPin);
    setMac(mac);
    if (!entropy.isEmpty()) {
        grantPin(newPin);
        setEntropy(entropy);
        clearGrant();
    }
    newPin.fill('\0');
    entropy.fill('\0');
    mac.fill('\0');
    return true;
}

QByteArray HDKey::EncryptString(QString str, QString key)
{
    QAESEncryption encryption(QAESEncryption::AES_256, QAESEncryption::CBC);
    QByteArray hashKey = QCryptographicHash::hash(SETS_ORG, QCryptographicHash::Sha256);
    if (!key.isEmpty()) {
        hashKey = QCryptographicHash::hash((hashKey + key).toLocal8Bit(), QCryptographicHash::Sha256);
    }
    QByteArray hashIV = QCryptographicHash::hash(SETS_APP, QCryptographicHash::Md5);
    QByteArray encoded = encryption.encode(str.toLocal8Bit(), hashKey, hashIV);
    str.fill('\0');
    key.fill('\0');
    return encoded;
}

QString HDKey::DecryptString(QByteArray ba, QString key)
{
    if (ba.length() < 16 || ba.length() % 16 != 0) {
        return "";
    }
    QAESEncryption encryption(QAESEncryption::AES_256, QAESEncryption::CBC);
    QByteArray hashKey = QCryptographicHash::hash(SETS_ORG, QCryptographicHash::Sha256);
    if (!key.isEmpty()) {
        hashKey = QCryptographicHash::hash((hashKey + key).toLocal8Bit(), QCryptographicHash::Sha256);
    }
    QByteArray hashIV = QCryptographicHash::hash(SETS_APP, QCryptographicHash::Md5);
    QByteArray decodeText = encryption.decode(ba, hashKey, hashIV);
    QString decodedString = QString(encryption.removePadding(decodeText));
    ba.fill('\0');
    key.fill('\0');
    return decodedString;
}

QString HDKey::randomHexString(int length)
{
    qsrand(QDateTime::currentMSecsSinceEpoch());

    const char ch[] = "0123456789ABCDEF";
    int size = sizeof(ch);

    char* str = new char[length + 1];
    str[length] = '\0';

    int num = 0;
    for (int i = 0; i < length; ++i) {
        num = rand() % (size - 1);
        str[i] = ch[num];
    }

    QString res(str);
    delete []str;

    QString hash = calcMac(res + _seed + SETS_ORG SETS_APP);
    res.insert(0, hash);
    res.resize(length);

    return res;
}

void HDKey::srandSeed(QString seed)
{
    _seed = seed;
}
