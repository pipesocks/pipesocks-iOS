//
//  Tap.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/7.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation
import CocoaAsyncSocket
import NetworkExtension

class Tap:NSObject,GCDAsyncSocketDelegate {

    var csock:TCPSocket?
    var ssock:SecureSocket?
    var password:String=""
    var remotePort:UInt16=0
    var taps:[UInt16:Tap]=[:]

    init(socket: TCPSocket, tunnelProvider: NEPacketTunnelProvider, remoteHost: String, remotePort: UInt16, password: String, taps: [UInt16:Tap]) {
        super.init()
        self.password=password
        self.remotePort=remotePort
        self.taps=taps
        csock=socket
        ssock=SecureSocket.init(tunnelProvider: tunnelProvider, password: password)
        ssock?.connect(remoteHost: remoteHost, remotePort: remotePort)
    }
}
