//
//  VPNCore.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/1.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

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
        manager?.saveToPreferences(completionHandler: { (err) in
            if err != nil {
                self.manager=nil
                completionHandler(false)
                return
            }
            self.manager?.loadFromPreferences(completionHandler: { (err) in
                do {
                    try self.manager?.connection.startVPNTunnel()
                } catch {
                    print(error.localizedDescription)
                }
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
