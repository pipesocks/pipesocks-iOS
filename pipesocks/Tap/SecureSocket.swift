//
//  SecureSocket.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/7.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation
import NetworkExtension
import Sodium

class SecureSocket {

    var password:String=""
    var tunnelProvider:NEPacketTunnelProvider?
    var tcpConnection:NWTCPConnection?
    let sodium=Sodium.init()
    var keyPair:Box.KeyPair?

    init(tunnelProvider: NEPacketTunnelProvider, password: String) {
        self.tunnelProvider=tunnelProvider
        self.password=password
        keyPair=sodium?.box.keyPair()
    }

    func connect(remoteHost: String, remotePort: UInt16) {
        tcpConnection=tunnelProvider?.createTCPConnection(to: NWHostEndpoint.init(hostname: remoteHost, port: "\(remotePort)"), enableTLS: false, tlsParameters: nil, delegate: nil)
    }
}
