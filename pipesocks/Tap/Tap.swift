//
//  Tap.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/7.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation

class Tap {

    var csock:TCPSocket?
    var ssock:SecureSocket?

    init (socket: TCPSocket, remoteHost: String, remotePort: String, password: String) {
        csock=socket
        ssock=SecureSocket.init(password: password)
        ssock?.connect(remoteHost: remoteHost, remotePort: remotePort)
    }
}
