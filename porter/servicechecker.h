/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#ifndef _SERVICECHECKER_H_
#define _SERVICECHECKER_H_


#include <QObject>
#include <QTimer>


// service checker for ios screen off
class ServiceChecker : public QObject
{
    Q_OBJECT
public:
    static ServiceChecker *instance();

public slots:
    void onTimer();

private:
    ServiceChecker();
    QTimer _timer;
};


#endif //_SERVICECHECKER_H_
