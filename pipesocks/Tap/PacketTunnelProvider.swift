//
//  PacketTunnelProvider.swift
//  Tap
//
//  Created by Jerry Zhou on 02/2.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    let defaultServerPort:UInt16=7473
    var server:TCPServer?

    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        let settings=NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: "5.20.13.14")
        settings.iPv4Settings=NEIPv4Settings.init(addresses: ["98.97.12.18"], subnetMasks: ["255.255.255.255"])
        settings.iPv4Settings?.includedRoutes=[NEIPv4Route.default()]
        settings.dnsSettings=NEDNSSettings.init(servers: ["8.8.8.8", "8.8.4.4"])
        settings.proxySettings?.autoProxyConfigurationEnabled=true
        settings.proxySettings?.proxyAutoConfigurationJavaScript="function FindProxyForURL(url,host){return\"SOCKS 127.0.0.1:\(defaultServerPort)\"}"
        settings.proxySettings?.excludeSimpleHostnames=true
        settings.tunnelOverheadBytes=150
        settings.mtu=1500
        let config:[String:Any]=(self.protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!
        server=TCPServer.init(config: config)
        setTunnelNetworkSettings(settings) { (err) in
            self.server?.start(port: self.defaultServerPort)
            completionHandler(err)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        server?.stop()
        completionHandler()
    }
}
