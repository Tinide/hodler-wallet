/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#include "servicechecker.h"
#ifdef Q_OS_IOS
extern "C" void CoinsrpcStartRPCMain(long);
#endif


ServiceChecker *__service_checker_ = NULL;

ServiceChecker::ServiceChecker()
{
#ifdef Q_OS_IOS
    connect(&_timer, SIGNAL(timeout()), this, SLOT(onTimer()));
    _timer.setInterval(5000);
    _timer.start();
#endif
}

ServiceChecker *ServiceChecker::instance()
{
    if (__service_checker_ == NULL) {
        __service_checker_ = new ServiceChecker;
    }
    return __service_checker_;
}

void ServiceChecker::onTimer()
{
#ifdef Q_OS_IOS
    CoinsrpcStartRPCMain(34911);
#endif
}
