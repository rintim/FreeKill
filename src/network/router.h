#ifndef _ROUTER_H
#define _ROUTER_H

#include <QObject>
#include <QDateTime>
#include <QMutex>
#include <QVariant>
#include <QSemaphore>
#include "client_socket.h"

class Router : public QObject {
    Q_OBJECT

public:
    enum PacketType {
        TYPE_REQUEST = 0x100,
        TYPE_REPLY = 0x200,
        TYPE_NOTIFICATION = 0x400,
        SRC_CLIENT = 0x010,
        SRC_SERVER = 0x020,
        SRC_LOBBY = 0x040,
        DEST_CLIENT = 0x001,
        DEST_SERVER = 0x002,
        DEST_LOBBY = 0x004
    };

    enum RouterType {
        TYPE_SERVER,
        TYPE_CLIENT
    };
    Router(QObject *parent, ClientSocket *socket, RouterType type);
    ~Router();

    ClientSocket *getSocket() const;
    void setSocket(ClientSocket *socket);

    void setReplyReadySemaphore(QSemaphore *semaphore);

    void request(int type, const QString &command,
                 const QString &json_data, int timeout);
    void reply(int type, const QString &command, const QString &json_data);
    void notify(int type, const QString &command, const QString &json_data);

    int getTimeout() const;

    void cancelRequest();

    QString waitForReply();
    QString waitForReply(int timeout);

signals:
    void messageReady(const QByteArray &message);
    void unknownPacket(const QByteArray &packet);
    void replyReady();

protected:
    void abortRequest();
    void handlePacket(const QByteArray &rawPacket);

private:
    ClientSocket *socket;
    RouterType type;

    // For sender
    int requestId;
    int requestTimeout;

    // For receiver
    QDateTime requestStartTime;
    QMutex replyMutex;
    int expectedReplyId;
    int replyTimeout;
    QString m_reply;        // should be json string
    QSemaphore replyReadySemaphore;
    QSemaphore *extraReplyReadySemaphore;

    // Two Lua global table for callbacks and interactions
    // stored in the lua_State of the sender
    // LuaTable interactions;
    // LuaTable callbacks;
};

#endif // _ROUTER_H
