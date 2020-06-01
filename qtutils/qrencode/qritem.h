#ifndef QRITEM_H_
#define QRITEM_H_

#include <QtQuick>


class QRItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QString qrData READ qrdata WRITE setQrdata NOTIFY qrdataChanged)

public:
    QRItem(QQuickItem *parent = nullptr);
    void paint(QPainter *painter);

    Q_INVOKABLE QString qrdata();
    Q_INVOKABLE void setQrdata(QString data);

signals:
    void qrdataChanged();

private:
    QString _qrdata;
};

#endif //QRITEM_H_
