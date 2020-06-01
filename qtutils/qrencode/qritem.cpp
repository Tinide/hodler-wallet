#include "qritem.h"
#include "qrencode.h"


QRItem::QRItem(QQuickItem *parent) : QQuickPaintedItem(parent)
{
}

QString QRItem::qrdata()
{
    return _qrdata;
}

void QRItem::setQrdata(QString data)
{
    _qrdata = data;
    update();
    emit qrdataChanged();
}

void QRItem::paint(QPainter *painter)
{
    QRcode *qr = QRcode_encodeString(_qrdata.toLatin1().data(),
                                     1, QR_ECLEVEL_L, QR_MODE_8, 1);
    if (qr == NULL) {
        return;
    }
    QColor fg("black");
    QColor bg("white");
    painter->setBrush(bg);
    painter->setPen(Qt::NoPen);
    painter->drawRect(0, 0, width(), height());
    painter->setBrush(fg);
    const int s = qr->width>0 ? qr->width : 1;
    const double w = width();
    const double h = height();
    const double aspect = w / h;
    const double scale = ((aspect > 1.0) ? h : w) / s;
    for (int y = 0; y < s; y++) {
        const int yy = y * s;
        for (int x = 0; x < s; x++) {
            const int xx = yy + x;
            const unsigned char b = qr->data[xx];
            if (b & 0x01) {
                const double rx1 = x * scale, ry1 = y * scale;
                QRectF r(rx1, ry1, scale, scale);
                painter->drawRects(&r, 1);
            }
        }
    }
    QRcode_free(qr);
}
