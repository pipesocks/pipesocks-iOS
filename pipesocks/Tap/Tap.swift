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
import Sodium

class Tap {

    var csock:TCPSocket?
    var ssock:SecureSocket?
    var password:String=""
    var remotePort:UInt16=0
    var taps:[UInt16:Tap]=[:]
    let sodium=Sodium.init()

    init(socket: TCPSocket, tunnelProvider: NEPacketTunnelProvider, remoteHost: String, remotePort: UInt16, password: String, taps: [UInt16:Tap]) {
        self.password=password
        self.remotePort=remotePort
        self.taps=taps
        csock=socket
        csock?.setTap(tap: self)
        ssock=SecureSocket.init(tunnelProvider: tunnelProvider, password: password)
        ssock?.setTap(tap: self)
        ssock?.connect(remoteHost: remoteHost, remotePort: remotePort)
    }

    func recvClient(data: Data) {
        //csock?.sendData(data: (sodium?.utils.hex2bin("0500"))!)
    }

    func recvServer(data: Data) {
        
    }

    func disconnected() {
        csock?.disconnect()
        ssock?.disconnect()
        taps.removeValue(forKey: remotePort)
    }
}
