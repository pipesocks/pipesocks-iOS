//
//  SecureSocket.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/7.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation

class SecureSocket:TCPSocket {

    var password:String=""

    init(password: String) {
        super.init()
        self.password=password
    }
}
