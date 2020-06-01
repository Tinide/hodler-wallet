/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#include "ImageDecoder.h"
#include <QSharedPointer>
#include <QQuickItemGrabResult>
#include <QDebug>
#include "ThreadBase.h"

ImageDecoder *__image_decoder = NULL;

ImageDecoder *ImageDecoder::instance()
{
    if (__image_decoder == NULL) {
        __image_decoder = new ImageDecoder;
        ThreadBase<ImageDecoder> *t = new ThreadBase<ImageDecoder>(__image_decoder, &ImageDecoder::decodeThread);
        t->start(NULL, NULL, NULL);
    }
    return __image_decoder;
}

ImageDecoder::ImageDecoder(QObject *parent) : QObject(parent) {
    _dec.setDecoder(  QZXing::DecoderFormat_Aztec
                    | QZXing::DecoderFormat_DATA_MATRIX
                    | QZXing::DecoderFormat_QR_CODE
                    | QZXing::DecoderFormat_CODE_39
                    | QZXing::DecoderFormat_EAN_13
                    | QZXing::DecoderFormat_MAXICODE);
}

void ImageDecoder::decodeImage(QImage image)
{
    _mutex.lock();
    _frame = image;
    _cond.wakeAll();
    _mutex.unlock();
}

void ImageDecoder::decodeItem(QObject *item)
{
    QQuickItemGrabResult *r = qobject_cast<QQuickItemGrabResult*>(item);
    _mutex.lock();
    _frame = r->image();
    _cond.wakeAll();
    _mutex.unlock();
}

int ImageDecoder::decodeThread(void *, void *)
{
    for (;;) {
        _mutex.lock();
        _cond.wait(&_mutex);
        QImage image = _frame;
        _mutex.unlock();

        if (image.isNull()) {
            QThread::msleep(100);
            continue;
        }

        QString qr = _dec.decodeImage(image);
        if (!qr.isEmpty()) {
            emit qrResult(qr);
        }
    }
    return 0;
}
