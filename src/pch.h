// SPDX-License-Identifier: GPL-3.0-or-later

#ifndef _PCH_H
#define _PCH_H

// core gui qml
#include <QtCore>

// network
#include <QTcpServer>
#include <QTcpSocket>

// other libraries
typedef int LuaFunction;
#include "lua.hpp"
#include "sqlite3.h"
#define OPENSSL_API_COMPAT 0x10101000L

#if !defined (Q_OS_ANDROID) && !defined (Q_OS_WASM)
#define DESKTOP_BUILD
#endif

#if defined(Q_OS_WASM)
#define FK_CLIENT_ONLY
#endif

// You may define FK_SERVER_ONLY with cmake .. -D...
#ifndef FK_SERVER_ONLY
#include <QApplication>
#include <QtQml>
#endif

#endif // _PCH_H
