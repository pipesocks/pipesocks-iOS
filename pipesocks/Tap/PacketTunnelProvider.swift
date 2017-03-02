//
//  PacketTunnelProvider.swift
//  Tap
//
//  Created by Jerry Zhou on 02/2.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import NetworkExtension
import NEKit

class PacketTunnelProvider: NEPacketTunnelProvider {

    let defaultServerPort:UInt16=7473
    var proxyServer:ProxyServer?

    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        let config:[String:Any]=(protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!
        let pipesocksAdapterFactory = PipesocksAdapterFactory.init(remoteHost: config["remoteHost"] as! String, remotePort: config["remotePort"] as! UInt16, password: config["password"] as! String)
        let allRule=AllRule.init(adapterFactory: pipesocksAdapterFactory)
        let manager=RuleManager(fromRules: [allRule], appendDirect: true)
        RuleManager.currentManager=manager
        RawSocketFactory.TunnelProvider=self
        let settings=NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: "5.20.13.14")
        settings.iPv4Settings=NEIPv4Settings.init(addresses: ["98.97.12.18"], subnetMasks: ["255.255.255.255"])
        settings.iPv4Settings?.includedRoutes=[NEIPv4Route.default()]
        settings.dnsSettings=NEDNSSettings.init(servers: ["8.8.8.8", "8.8.4.4"])
        settings.proxySettings=NEProxySettings.init()
        settings.proxySettings?.httpEnabled=true
        settings.proxySettings?.httpServer=NEProxyServer.init(address: "127.0.0.1", port: 7473)
        settings.proxySettings?.httpsEnabled=true
        settings.proxySettings?.httpsServer=NEProxyServer.init(address: "127.0.0.1", port: 7473)
        settings.proxySettings?.excludeSimpleHostnames=true
        settings.proxySettings?.matchDomains=[""]
        settings.tunnelOverheadBytes=150
        settings.mtu=1500
        setTunnelNetworkSettings(settings) { (err) in
            self.proxyServer=GCDHTTPProxyServer(address: IPAddress.init(fromString: "127.0.0.1"), port: Port.init(port: self.defaultServerPort))
            try! self.proxyServer?.start()
            completionHandler(err)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        proxyServer?.stop()
        proxyServer=nil
        RawSocketFactory.TunnelProvider=nil
        completionHandler()
    }
}
