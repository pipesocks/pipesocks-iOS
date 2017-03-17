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

    init(completionHandler: @escaping () -> Void) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, err) in
            if err==nil&&managers!.count>0 {
                self.manager=managers?[0]
            }
            completionHandler()
        }
    }

    func status() -> NEVPNStatus {
        if manager==nil {
            return NEVPNStatus.invalid
        }
        return manager!.connection.status
    }

    func start() {
        if status()==NEVPNStatus.connected||status()==NEVPNStatus.connecting {
            return
        } else {
            try! self.manager?.connection.startVPNTunnel()
        }
    }

    func stop() {
        if status()==NEVPNStatus.disconnected||status()==NEVPNStatus.disconnecting {
            return
        } else {
            self.manager?.connection.stopVPNTunnel()
        }
    }

    func setConfig(config: [String:Any], completionHandler:@escaping (_:Bool) -> Void) {
        if status()==NEVPNStatus.invalid {
            manager=NETunnelProviderManager.init()
        }
        manager?.localizedDescription="pipesocks Tap"
        let ptc=NETunnelProviderProtocol.init()
        ptc.serverAddress="pipesocks Pump"
        ptc.providerBundleIdentifier="tk.yvbbrjdr.pipesocks.Tap"
        ptc.providerConfiguration=config
        manager?.protocolConfiguration=ptc
        manager?.isEnabled=true
        manager?.saveToPreferences(completionHandler: { (err) in
            if err==nil {
                self.manager?.loadFromPreferences(completionHandler: { (err) in
                    completionHandler(true)
                })
            } else {
                completionHandler(false)
            }
        })
    }

    func getConfig() -> [String:Any]? {
        if status()==NEVPNStatus.invalid {
            return nil
        } else {
            return (manager?.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration
        }
    }
}
