/* ==============================================================
              GNU GENERAL PUBLIC LICENSE

   Copyright © 2020 yancaitech <yancaitech@gmail.com>
   Contact: https://github.com/yancaitech

   You may use, distribute and copy the Source Code under the terms of
   GNU General Public License version 3.
// ==============================================================*/

#include "store.h"
#include "porter.h"
#include <QStandardPaths>
#include <QDir>
#include <QSettings>
#include <QDebug>
#include <QSqlQuery>
#include <QSqlRecord>
#include <QSqlError>
#include <QSqlQueryModel>
#include <QJsonDocument>
#include <QJsonArray>
#include <QJsonObject>
#include <QDateTime>
#include <QLocale>
#include <QVariant>



void HDStore::setLanguage(int lang)
{
    QSettings sets(SETS_ORG, SETS_APP);
    sets.setValue("language", lang);
    emit languageChanged();
}

int HDStore::getLanguage()
{
    QSettings sets(SETS_ORG, SETS_APP);
    int lang = sets.value("language", -1).toInt();
    if (lang == -1) {
        QLocale local = QLocale::system();
        switch (local.language()) {
        case QLocale::English:
            lang = 0;
            break;
        case QLocale::Japanese:
            lang = 1;
            break;
        case QLocale::Korean:
            lang = 2;
            break;
        case QLocale::German:
            lang = 3;
            break;
        case QLocale::French:
            lang = 4;
            break;
        case QLocale::Italian:
            lang = 5;
            break;
        case QLocale::Polish:
            lang = 6;
            break;
        case QLocale::Spanish:
            lang = 7;
            break;
        case QLocale::Afrikaans:
            lang = 8;
            break;
        case QLocale::Chinese:
            lang = 9;
            break;
        default:
            lang = 0;
            break;
        }
        if (local.country() == QLocale::China) {
            lang = 10;
        }
        sets.setValue("language", lang);
    }

    return lang;
}

void HDStore::setTheme(int theme)
{
    QSettings sets(SETS_ORG, SETS_APP);
    sets.setValue("theme", theme);
    emit themeChanged();
}

int HDStore::getTheme()
{
    QSettings sets(SETS_ORG, SETS_APP);
    int theme = sets.value("theme", 1).toInt();
    return theme;
}

void HDStore::setQRCapacity(int capacity)
{
    QSettings sets(SETS_ORG, SETS_APP);
    sets.setValue("qrcapacity", capacity);
    emit qrcapacityChanged();
}

int HDStore::getQRCapacity()
{
    QSettings sets(SETS_ORG, SETS_APP);
    int val = sets.value("qrcapacity", 304).toInt();
    return val;
}

void HDStore::setFontSize(int size)
{
    QSettings sets(SETS_ORG, SETS_APP);
    sets.setValue("fontsize", size);
    emit qrcapacityChanged();
}

int HDStore::getFontSize()
{
    QSettings sets(SETS_ORG, SETS_APP);
    int val = sets.value("fontsize", -1).toInt();
    return val;
}
