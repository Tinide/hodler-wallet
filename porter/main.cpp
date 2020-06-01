/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QFont>
#include <QSslSocket>
#include <QDebug>
#include <QSqlDatabase>
#include <QTextCodec>
#include "qjsonrpcclient.h"
#ifdef Q_OS_IOS
extern "C" void CoinsrpcStartRPCMain(long);
#include "servicechecker.h"
#endif
#ifdef Q_OS_WIN
#include <QProcess>
#endif
#include "ImageDecoder.h"
#include "porter.h"
#include "store.h"
#include "qritem.h"


QJsonRpcClient *__rpc = nullptr;

QObject *jsonRpcProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return __rpc;
}

QObject *qrProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return ImageDecoder::instance();
}

QObject *storeProvider(QQmlEngine *engine, QJSEngine *scriptEngine)
{
    Q_UNUSED(engine)
    Q_UNUSED(scriptEngine)
    return HDStore::instance();
}

void StartRPCMain(QGuiApplication &app)
{
#ifdef Q_OS_IOS
    CoinsrpcStartRPCMain(35911);
    ServiceChecker::instance();
#endif

#ifdef Q_OS_ANDROID
    return;
#endif

#if !defined(Q_OS_IOS) && !defined(Q_OS_ANDROID)
    qputenv("COINSRPCPORT", "35911");
    QString path = app.applicationDirPath();
    path.replace("\\", "/");
    QString rpcFile = "\"" + path + "/coinsrpc\"";
    static QProcess p;
    app.connect(&app, SIGNAL(lastWindowClosed()), &p, SLOT(kill()));
    p.start(rpcFile);
#endif
}

int main(int argc, char *argv[])
{
    qInfo() << QSslSocket::supportsSsl() << QSslSocket::sslLibraryBuildVersionString() << QSslSocket::sslLibraryVersionString();

    QSqlDatabase::addDatabase("QSQLITE");
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
    //QCoreApplication::setAttribute(Qt::AA_UseSoftwareOpenGL);
    QGuiApplication app(argc, argv);

    StartRPCMain(app);
    __rpc = new QJsonRpcClient;

    QFont font;
#ifdef Q_OS_WIN
    font.setPointSize(7);
    font.setFamily("Microsoft YaHei");
#endif
#ifdef Q_OS_ANDROID
    font.setPointSize(7);
    font.setFamily("Droid Sans");
#endif
#ifdef Q_OS_IOS
    QTextCodec::setCodecForLocale(QTextCodec::codecForName("UTF-8"));
    font.setPointSize(7);
    font.setFamily("Courier New");
#endif
    app.setFont(font);

    QQmlApplicationEngine engine;
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);

    qmlRegisterSingletonType<QJsonRpcClient>("HD.JsonRpc", 1, 0, "JsonRpc", jsonRpcProvider);
    qmlRegisterSingletonType<ImageDecoder>("HD.QRDecoder", 1, 0, "QRDecoder", qrProvider);
    qmlRegisterSingletonType<HDStore>("HD.Store", 1, 0, "Store", storeProvider);
    qmlRegisterType<QRItem>("QRCode", 1, 0, "QRItem");
    qmlRegisterSingletonType(QUrl("qrc:/config.qml"), "HD.Config", 1, 0, "Config");
    qmlRegisterSingletonType(QUrl("qrc:/language/Language.qml"), "HD.Language", 1, 0, "Lang");
    qmlRegisterSingletonType(QUrl("qrc:/common/Theme.qml"), "Theme", 1, 0, "Theme");
    qmlRegisterSingletonType(QUrl("qrc:/common/math/HDMath.qml"), "HD.Math", 1, 0, "HDMath");

    engine.load(url);
    app.exec();
    exit(0);
    return 0;
}
