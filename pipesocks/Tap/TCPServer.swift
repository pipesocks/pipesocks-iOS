//
//  TCPServer.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/7.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import NetworkExtension

class TCPServer:NSObject,GCDAsyncSocketDelegate {

    var remoteHost:String=""
    var remotePort:UInt16=0
    var password:String=""
    var listenSocket:GCDAsyncSocket?
    var tunnelProvider:NEPacketTunnelProvider?
    var taps:[Tap]=[]

    init(config: [String:Any], tunnelProvider: NEPacketTunnelProvider) {
        super.init()
        remoteHost=config["remoteHost"] as! String
        remotePort=config["remotePort"] as! UInt16
        password=config["password"] as! String
        self.tunnelProvider=tunnelProvider
        listenSocket=GCDAsyncSocket.init(delegate: self, delegateQueue: DispatchQueue.global())
    }

    func start(port: UInt16) {
        try! listenSocket?.accept(onInterface: "127.0.0.1", port: port)
    }

    func stop() {
        listenSocket?.disconnect()
    }

    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        taps.append(Tap.init(socket: sock, tunnelProvider: tunnelProvider!, remoteHost: remoteHost, remotePort: remotePort, password: password))
    }
}
