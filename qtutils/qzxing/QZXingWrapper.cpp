#include "QZXingWrapper.h"
#include "QZXing.h"

QZXingWrapper::QZXingWrapper(QObject *parent) : QObject(parent)
{

}


void QZXingWrapper::registerQMLTypes(){

    QZXing::registerQMLTypes();
}
