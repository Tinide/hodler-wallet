QT += quick sql multimedia
CONFIG += c++11

DEFINES += QT_DEPRECATED_WARNINGS

INCLUDEPATH += $$PWD/store

include($$PWD/../qtutils/rpcclient/qjsonrpcclient.pri)
include($$PWD/../qtutils/qrencode/qrencode.pri)
include($$PWD/../qtutils/qzxing/QZXing.pri)
include($$PWD/deployment.pri)

android {
    QT += androidextras
    CONFIG += qtquickcompiler

    include($$PWD/../qtutils/android_openssl-master/openssl.pri)

    DISTFILES += \
        android/res/drawable-hdpi/icon.png \
        android/res/drawable-ldpi/icon.png \
        android/res/drawable-mdpi/icon.png \
        android/res/drawable-xhdpi/product_logo.png \
        android/res/drawable-xhdpi/splash_back.png \
        android/res/drawable/splashscreen.xml \
        android/res/layout/activity_splash.xml \
        android/res/values/styles.xml \
        android/res/values/colors.xml \
        android/AndroidManifest.xml \
        android/build.gradle \
        android/libs/coinsrpc.aar \
        android/src/org/yancaitech/porter/SplashActivity.java

    ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android
}

ios {
#    disable_bitcode.name = "ENABLE_BITCODE"
#    disable_bitcode.value = NO
#    QMAKE_MAC_XCODE_SETTINGS += disable_bitcode

#    CONFIG -= bitcode

    LIBS += -F$$PWD/../hodler/ios
    LIBS += -framework Coinsrpc

#    errors, use XCode import manually
#    MY_FRAMEWORK.files = $$PWD/ios/Coinsrpc.framework
#    MY_FRAMEWORK.path = /Frameworks
#    QMAKE_BUNDLE_DATA += MY_FRAMEWORK
#    QMAKE_LFLAGS += -Wl,-rpath,@loader_path/Frameworks

#    app_launch_images.files = $$PWD/ios/Launch.xib $$PWD/ios/Assets.xcassets
#    QMAKE_BUNDLE_DATA += app_launch_images
#    ICON = $$_PRO_FILE_PWD_/Icon.icns
#    QMAKE_INFO_PLIST = $$PWD/ios/Info.plist
}

win32 {
    DESTDIR = bin

    RC_ICONS = ./images/porter.ico

    rpcbin.source = ../hodler/win/*
    rpcbin.target = ./bin
    DEPLOYMENTFOLDERS += rpcbin
}

macos {
    ICON = $$_PRO_FILE_PWD_/images/porter.icns

    QMAKE_LFLAGS += -Wl,-rpath,@loader_path/../Frameworks,-rpath,@executable_path/../Frameworks
    #QMAKE_LFLAGS += -Wl,-install_name,@executable_path/../Frameworks/
    #QMAKE_RPATHDIR += @loader_path/../Frameworks

    QMAKE_POST_LINK += plutil -replace NSCameraUsageDescription -string \"Porter want to use Camera\" $${TARGET}.app/Contents/Info.plist

    appbin = "$$OUT_PWD/porter.app/Contents/MacOS/"
    rpcbin = "$$_PRO_FILE_PWD_/../hodler/macos/coinsrpc"
    system("cp $$rpcbin $$appbin")
}

linux {
    appbin = "$$OUT_PWD/"
    rpcbin = "$$_PRO_FILE_PWD_/linux/coinsrpc"
    system("cp $$rpcbin $$appbin")
}

SOURCES += \
        main.cpp \
        servicechecker.cpp \
        store/store+address.cpp \
        store/store+service.cpp \
        store/store+settings.cpp \
        store/store+transaction.cpp \
        store/store.cpp

RESOURCES += qml.qrc \
    $$PWD/../qtutils/qmlcommon/common.qrc

HEADERS += \
    porter.h \
    servicechecker.h \
    store/store.h


qtcAddDeployment()
