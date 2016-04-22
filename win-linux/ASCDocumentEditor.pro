
QT  += core gui widgets gui-private widgets-private core-private printsupport

TEMPLATE = app
CONFIG += app_bundle
CONFIG += c++11
#CONFIG += console

TARGET = DesktopEditors

TRANSLATIONS = ./langs/en.ts \
                ./langs/ru.ts \
                ./langs/de.ts \
                ./langs/es.ts \
                ./langs/fr.ts

CORE_SRC_PATH = ../../core/DesktopEditor
CORE_LIB_PATH = ../../core/Build

INCLUDEPATH += $$CORE_SRC_PATH/ChromiumBasedEditors2/lib/include \
                $$CORE_SRC_PATH/ChromiumBasedEditors2/lib/qcefview \
                $$CORE_SRC_PATH

HEADERS += \
    $$CORE_SRC_PATH/ChromiumBasedEditors2/lib/qcefview/qcefview.h \
    ./src/asctabwidget.h \
    src/cascuser.h \
    src/version.h \
    src/csavefilemessage.h \
    src/cuserprofilewidget.h \
    src/defines.h \
    src/cdownloadwidget.h \
    src/cpushbutton.h \
#    src/cmyapplicationmanager.h \
    src/cfiledialog.h \
    src/cprintprogress.h \
    src/ccefeventstransformer.h \
    src/qascmainpanel.h \
    src/cascapplicationmanagerwrapper.h \
    src/cchooselicensedialog.h \
    src/ctabbar.h \
    src/casctabdata.h \
    src/cmessage.h \
    src/utils.h \
    src/cstyletweaks.h \
    src/csplash.h \
    src/chelp.h
#    src/ctabbar_p.h \
#    src/ctabstyle.h \
#    src/ctabstyle_p.h
#    src/casclabel.h

SOURCES += \
    ./src/main.cpp \
    ./src/asctabwidget.cpp\
    $$CORE_SRC_PATH/ChromiumBasedEditors2/lib/qcefview/qcefview.cpp \
    src/cascuser.cpp \
    src/csavefilemessage.cpp \
    src/cuserprofilewidget.cpp \
    src/cdownloadwidget.cpp \
    src/cpushbutton.cpp \
    src/cfiledialog.cpp \
    src/cprintprogress.cpp \
    src/ccefeventstransformer.cpp \
    src/cchooselicensedialog.cpp \
    src/qascmainpanel.cpp \
    src/ctabbar.cpp \
    src/casctabdata.cpp \
    src/cmessage.cpp \
    src/utils.cpp \
    src/cstyletweaks.cpp \
    src/csplash.cpp \
    src/chelp.cpp
#    src/ctabstyle.cpp
#    src/casclabel.cpp

#CONFIG += ivolga_theme
#CONFIG += avs_theme

RESOURCES += resources.qrc
RC_FILE = version.rc
#RES_FILE = version.res

ivolga_theme {
    DEFINES += _IVOLGA_PRO
    RESOURCES += res/ivolga.qrc
}

avs_theme {
    DEFINES += _AVS
    RESOURCES += res/avs.qrc
}

DEFINES += \
    _QT \
    FT2_BUILD_LIBRARY \
    EXCLUDE_JPG_SUPPORT \
    MNG_SUPPORT_DISPLAY \
    MNG_SUPPORT_READ \
    MNG_SUPPORT_WRITE \
    MNG_ACCESS_CHUNKS \
    MNG_STORE_CHUNKS\
    MNG_ERROR_TELLTALE

linux-g++ {
    contains(QMAKE_HOST.arch, x86_64):{
        PLATFORM_BUILD = linux_64
    } else {
        PLATFORM_BUILD = linux_32
    }

    QT += x11extras

    QMAKE_LFLAGS += "-Wl,-rpath,\'\$$ORIGIN\'"
    QMAKE_LFLAGS += "-Wl,-rpath,\'\$$ORIGIN/converter\'"
    QMAKE_LFLAGS += -static-libstdc++ -static-libgcc

    LIBS += -L$$PWD/$$CORE_LIB_PATH/cef/$$PLATFORM_BUILD -lcef
    LIBS += -L$$PWD/$$CORE_LIB_PATH/lib/$$PLATFORM_BUILD -lascdocumentscore
    LIBS += -L$$PWD/$$CORE_LIB_PATH/lib/$$PLATFORM_BUILD -lDjVuFile -lXpsFile -lPdfReader -lPdfWriter

    HEADERS += src/linux/cmainwindow.h \
                src/linux/cx11decoration.h
    SOURCES += src/linux/cmainwindow.cpp \
                src/linux/cx11decoration.cpp

    DEFINES += LINUX _LINUX _LINUX_QT
    CONFIG += link_pkgconfig
    PKGCONFIG += glib-2.0 gdk-2.0 gtkglext-1.0 atk cairo gtk+-unix-print-2.0

    build_for_centos6 {
        QMAKE_LFLAGS += -Wl,--dynamic-linker=./ld-linux-x86-64.so.2
    }

    message($$PLATFORM_BUILD)
}


win32 {
    DEFINES += JAS_WIN_MSVC_BUILD WIN32
    RC_ICONS += ./res/icons/desktop_icons.ico

    HEADERS += ./src/win/mainwindow.h \
                ./src/win/qwinwidget.h \
                ./src/win/qwinhost.h \
                ./src/win/cwinpanel.h \
                ./src/win/cprintdialog.h

    SOURCES += ./src/win/mainwindow.cpp \
                ./src/win/qwinwidget.cpp \
                ./src/win/qwinhost.cpp \
                ./src/win/cwinpanel.cpp \
                ./src/cprintdialog.cpp

    LIBS += -lwininet \
            -ldnsapi \
            -lversion \
            -lmsimg32 \
            -lws2_32 \
            -lusp10 \
            -lpsapi \
            -ldbghelp \
            -lwinmm \
            -lshlwapi \
            -lkernel32 \
            -lgdi32 \
            -lwinspool \
            -lcomdlg32 \
            -ladvapi32 \
            -lshell32 \
            -lole32 \
            -loleaut32 \
            -luser32 \
            -luuid \
            -lodbc32 \
            -lodbccp32 \
            -ldelayimp \
            -lcredui \
            -lnetapi32 \
            -lcomctl32 \
            -lrpcrt4
#            -ldwmapi
#            -lOpenGL32

#    PRE_TARGETDEPS += ../common/converter/windows/x64/DjVuFile.dll \
#                        ../common/converter/windows/x64/PdfReader.dll \
#                        ../common/converter/windows/x64/PdfWriter.dll \
#                        ../common/converter/windows/x64/XpsFile.dll

    contains(QMAKE_TARGET.arch, x86_64):{
        QMAKE_LFLAGS_WINDOWS = /SUBSYSTEM:WINDOWS,5.02
        PLATFORM_BUILD = win_64
    } else {
        QMAKE_LFLAGS_WINDOWS = /SUBSYSTEM:WINDOWS,5.01
        PLATFORM_BUILD = win_32
    }

    CONFIG += updmodule
    updmodule {
        DEFINES += _UPDMODULE
        LIBS += -L$$PWD/3dparty/WinSparkle/$$PLATFORM_BUILD -lWinSparkle
    }

    LIBS += -L$$PWD/$$CORE_LIB_PATH/cef/$$PLATFORM_BUILD -llibcef
    CONFIG(debug, debug|release) {
        LIBS += -L$$PWD/$$CORE_LIB_PATH/lib/$$PLATFORM_BUILD/debug -lascdocumentscore
    } else {
        LIBS += -L$$PWD/$$CORE_LIB_PATH/lib/$$PLATFORM_BUILD -lascdocumentscore

        ivolga_theme {
            TARGET = IvolgaPRO
        }

        avs_theme {
            TARGET = AVSDocumentEditor
        }
    }

    message($$PLATFORM_BUILD)
}
