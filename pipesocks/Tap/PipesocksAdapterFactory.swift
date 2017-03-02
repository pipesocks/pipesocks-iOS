//
//  PipesocksAdapterFactory.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/26.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation
import NEKit

class PipesocksAdapterFactory: AdapterFactory {

    var remoteHost:String=""
    var remotePort:UInt16=0
    var password:String=""

    init(remoteHost: String, remotePort: UInt16, password: String) {
        self.remoteHost=remoteHost
        self.remotePort=remotePort
        self.password=password
    }

    override func getAdapterFor(session: ConnectSession) -> AdapterSocket {
        let adapter=PipesocksAdapter.init(remoteHost: remoteHost, remotePort: remotePort, password: password)
        adapter.socket=RawSocketFactory.getRawSocket()
        return adapter
    }
}
