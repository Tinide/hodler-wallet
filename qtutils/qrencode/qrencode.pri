CONFIG += qt

INCLUDEPATH  += $$PWD
DEFINES += HAVE_CONFIG_H

HEADERS += $$PWD/qritem.h \
		    $$PWD/bitstream.h \
			$$PWD/config.h \
			$$PWD/mask.h \
			$$PWD/mmask.h \
			$$PWD/mqrspec.h \
			$$PWD/qrencode.h \
			$$PWD/qrencode_inner.h \
			$$PWD/qrinput.h \
			$$PWD/qrspec.h \
			$$PWD/rsecc.h \
			$$PWD/split.h

SOURCES += $$PWD/qritem.cpp \
        $$PWD/bitstream.c \
        $$PWD/mask.c \
        $$PWD/mmask.c \
        $$PWD/mqrspec.c \
        $$PWD/qrencode.c \
        $$PWD/qrinput.c \
        $$PWD/qrspec.c \
        $$PWD/rsecc.c \
        $$PWD/split.c
