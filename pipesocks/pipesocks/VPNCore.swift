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

    init() {
        NETunnelProviderManager.loadAllFromPreferences { (managers, err) in
            if (managers?.count)!>0 {
                self.manager=managers?[0]
            } else {
                self.manager=NETunnelProviderManager.init()
                self.manager?.protocolConfiguration=NETunnelProviderProtocol.init()
                self.manager?.localizedDescription="pipesocks Tap"
                self.manager?.protocolConfiguration?.serverAddress="pipesocks Pump"
                self.manager?.saveToPreferences(completionHandler: { (err) in
                    if err != nil {
                        self.manager=nil
                    }
                })
            }
        }
    }

    func isValid() -> Bool {
        return manager != nil
    }

    func started() -> Bool {
        if !isValid() {
            return false
        }
        return (manager?.isEnabled)!
    }

    func start() {
        if started() {
            return
        }
    }

    func stop() {
        if !started() {
            return
        }
    }
}
