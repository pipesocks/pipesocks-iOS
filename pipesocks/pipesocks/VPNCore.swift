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

import NetworkExtension

class VPNCore {

    var manager:NETunnelProviderManager?

    init(completionHandler: @escaping (_:[String:Any]?, _:Bool) -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, err) in
            if err != nil||managers?.count==0 {
                completionHandler(nil, false)
                return
            }
            self.manager=managers?[0]
            let ptc:NETunnelProviderProtocol=self.manager?.protocolConfiguration as! NETunnelProviderProtocol
            completionHandler(ptc.providerConfiguration, self.started())
        }
    }

    func isValid() -> Bool {
        return manager != nil
    }

    func started() -> Bool {
        if !isValid() {
            return false
        }
        return manager?.connection.status==NEVPNStatus.connected
    }

    func start(remoteHost:String, remotePort:UInt16, password:String, completionHandler:@escaping (_:Bool) -> Void) {
        if started() {
            completionHandler(true)
            return
        }
        if !isValid() {
            manager=NETunnelProviderManager.init()
            manager?.localizedDescription="pipesocks Tap"
            let ptc=NETunnelProviderProtocol.init()
            ptc.serverAddress="pipesocks Pump"
            ptc.providerBundleIdentifier="tk.yvbbrjdr.pipesocks.Tap"
            manager?.protocolConfiguration=ptc
        }
        let ptc:NETunnelProviderProtocol=manager?.protocolConfiguration as! NETunnelProviderProtocol
        ptc.providerConfiguration=["remoteHost":remoteHost, "remotePort":remotePort, "password":password] as [String:Any]
        manager?.protocolConfiguration=ptc
        manager?.isEnabled=true
        manager?.saveToPreferences(completionHandler: { (err) in
            if err != nil {
                self.manager=nil
                completionHandler(false)
                return
            }
            self.manager?.loadFromPreferences(completionHandler: { (err) in
                try! self.manager?.connection.startVPNTunnel()
                completionHandler(true)
            })
        })
    }

    func stop() {
        if !started() {
            return
        }
        self.manager?.connection.stopVPNTunnel()
    }
}
