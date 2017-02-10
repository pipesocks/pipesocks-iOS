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

    init(socket: GCDAsyncSocket) {
        self.socket=socket
    }
}
