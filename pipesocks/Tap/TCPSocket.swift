//
//  TCPSocket.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/10.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation
import CocoaAsyncSocket

class TCPSocket:NSObject,GCDAsyncSocketDelegate {

    var socket:GCDAsyncSocket?
    var tap:Tap?

    init(socket: GCDAsyncSocket) {
        super.init()
        self.socket=socket
        socket.setDelegate(nil, delegateQueue: DispatchQueue.global())
        socket.synchronouslySetDelegate(self)
        socket.readData(withTimeout: -1, tag: 0)
    }

    func setTap(tap: Tap) {
        self.tap=tap
    }

    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        tap?.recvClient(data: data)
        socket?.readData(withTimeout: -1, tag: 0)
    }

    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        tap?.disconnected()
    }

    func disconnect() {
        socket?.disconnectAfterReadingAndWriting()
    }

    func sendData(data: Data) {
        socket?.write(data, withTimeout: -1, tag: 0)
    }
}
