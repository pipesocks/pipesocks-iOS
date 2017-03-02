//
//  PipesocksAdapter.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/26.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation
import NEKit

class PipesocksAdapter: AdapterSocket {

    var remoteHost:String=""
    var remotePort:UInt16=0
    var password:String=""

    init(remoteHost: String, remotePort: UInt16, password: String) {
        self.remoteHost=remoteHost
        self.remotePort=remotePort
        self.password=password
        super.init()
    }

    public override func openSocketWith(session: ConnectSession) {
        super.openSocketWith(session: session)
        guard !isCancelled else {
            return
        }
        try! socket.connectTo(host: remoteHost, port: Int.init(remotePort), enableTLS: false, tlsSettings: nil)
    }

    public override func didConnectWith(socket: RawTCPSocketProtocol) {
        super.didConnectWith(socket: socket)
        socket.write(data: password.data(using: String.Encoding.ascii)!)
    }

    public override func didRead(data: Data, from socket: RawTCPSocketProtocol) {
        super.didRead(data: data, from: socket)
    }

    override open func didWrite(data: Data?, by socket: RawTCPSocketProtocol) {
        super.didWrite(data: data, by: socket)
    }
}
