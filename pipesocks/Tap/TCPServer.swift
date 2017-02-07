//
//  TCPServer.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/7.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation

class TCPServer {

    var remoteHost:String=""
    var remotePort:String=""
    var password:String=""

    init(config: [String:Any]) {
        remoteHost=config["remoteHost"] as! String
        remotePort="\(config["remotePort"] as! UInt16)"
        password=config["password"] as! String
    }

    func start(port: UInt16) {
        
    }

    func stop() {
        
    }
}
