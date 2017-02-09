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

    var csock:GCDAsyncSocket?
    var ssock:SecureSocket?
    var password:String=""

    init(socket: GCDAsyncSocket, tunnelProvider: NEPacketTunnelProvider, remoteHost: String, remotePort: UInt16, password: String) {
        super.init()
        self.password=password
        csock=socket
        csock?.synchronouslySetDelegate(self)
        ssock=SecureSocket.init(tunnelProvider: tunnelProvider, password: password)
        ssock?.connect(remoteHost: remoteHost, remotePort: remotePort)
    }
}
