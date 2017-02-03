//
//  PacketTunnelProvider.swift
//  Tap
//
//  Created by Jerry Zhou on 02/2.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        let settings=NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: "1.1.1.1")
        settings.iPv4Settings=NEIPv4Settings.init(addresses: ["192.168.98.1"], subnetMasks: ["255.255.255.255"])
        settings.iPv4Settings?.includedRoutes=[NEIPv4Route.default()]
        settings.dnsSettings=NEDNSSettings.init(servers: ["8.8.8.8", "8.8.4.4"])
        settings.tunnelOverheadBytes=150
        settings.mtu=1500
        setTunnelNetworkSettings(settings) { (err) in
            let config:[String:Any]=(self.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!
            completionHandler(err)
        }
    }
}
