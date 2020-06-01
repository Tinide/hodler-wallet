#ifndef QZXINGWRAPPER_H
#define QZXINGWRAPPER_H

#include <QObject>
#include "QZXing_global.h"

// QZXing包装类 author:Tong

class QZXINGSHARED_EXPORT QZXingWrapper : public QObject
{
    Q_OBJECT
public:
    explicit QZXingWrapper(QObject *parent = nullptr);

    static void registerQMLTypes();

signals:

public slots:
};

#endif // QZXINGWRAPPER_H
