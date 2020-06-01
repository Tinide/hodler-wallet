/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#ifndef IMAGEDECODER_H
#define IMAGEDECODER_H

#include <QObject>
#include <QImage>
#include <QMutex>
#include <QQuickItem>
#include <QWaitCondition>
#include "QZXing.h"


class ImageDecoder : public QObject
{
    Q_OBJECT
public:
    static ImageDecoder *instance();

    Q_INVOKABLE void decodeImage(QImage image);
    Q_INVOKABLE void decodeItem(QObject *item);

signals:
    void qrResult(QString qr);

private:
    int decodeThread(void *p, void *q);

private:
    explicit ImageDecoder(QObject *parent = 0);
    QZXing _dec;
    QImage _frame;
    QMutex _mutex;
    QWaitCondition _cond;
    bool _active{false};
};

#endif // IMAGEDECODER_H
