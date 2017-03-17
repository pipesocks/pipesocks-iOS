/*
 This file is part of pipesocks-iOS. Pipesocks-iOS is a pipesocks tap running on iOS. Pipesocks is a pipe-like SOCKS5 tunnel system.
 Copyright (C) 2017  yvbbrjdr
 
 This program is free software: you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation, either version 3 of the License, or
 (at your option) any later version.
 
 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 GNU General Public License for more details.
 
 You should have received a copy of the GNU General Public License
 along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

import Foundation
import NEKit

class PipesocksAdapterFactory: AdapterFactory {

    var remoteHost:String=""
    var remotePort:UInt16=0
    var password:String=""
    var enableIPv6:Bool=false

    init(remoteHost: String, remotePort: UInt16, password: String, enableIPv6: Bool) {
        self.remoteHost=remoteHost
        self.remotePort=remotePort
        self.password=password
        self.enableIPv6=enableIPv6
    }

    override func getAdapterFor(session: ConnectSession) -> AdapterSocket {
        let adapter=PipesocksAdapter.init(remoteHost: remoteHost, remotePort: remotePort, password: password, enableIPv6: enableIPv6)
        adapter.socket=RawSocketFactory.getRawSocket()
        return adapter
    }
}
