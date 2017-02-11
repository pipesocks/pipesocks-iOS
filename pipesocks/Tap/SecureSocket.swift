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
    var tap:Tap?
    var recvBuffer=Data.init()

    init(tunnelProvider: NEPacketTunnelProvider, password: String) {
        self.tunnelProvider=tunnelProvider
        self.password=password
        keyPair=sodium?.box.keyPair()
    }

    func setTap(tap: Tap) {
        self.tap=tap
    }

    func connect(remoteHost: String, remotePort: UInt16) {
        tcpConnection=tunnelProvider?.createTCPConnection(to: NWHostEndpoint.init(hostname: remoteHost, port: "\(remotePort)"), enableTLS: false, tlsParameters: nil, delegate: nil)
        tcpConnection?.readLength(1000, completionHandler: getData)
    }

    func getData(data: Data?, err: Error?) {
        recvBuffer.append(data!)
        tcpConnection?.readLength(1000, completionHandler: getData)
    }

    func disconnect() {
        tcpConnection?.writeClose()
    }
}
