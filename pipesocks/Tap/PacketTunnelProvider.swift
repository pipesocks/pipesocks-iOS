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
import NEKit

class PacketTunnelProvider: NEPacketTunnelProvider {

    let defaultServerPort:UInt16=7473
    var proxyServer:ProxyServer?

    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        let config:[String:Any]=(protocolConfiguration as! NETunnelProviderProtocol).providerConfiguration!
        let pipesocksAdapterFactory=PipesocksAdapterFactory.init(remoteHost: config["remoteHost"] as! String, remotePort: config["remotePort"] as! UInt16, password: config["password"] as! String)
        let allRule=AllRule.init(adapterFactory: pipesocksAdapterFactory)
        let manager=RuleManager(fromRules: [allRule], appendDirect: true)
        RuleManager.currentManager=manager
        RawSocketFactory.TunnelProvider=self
        let settings=NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: "5.20.13.14")
        settings.iPv4Settings=NEIPv4Settings.init(addresses: ["98.97.12.18"], subnetMasks: ["255.255.255.255"])
        settings.proxySettings=NEProxySettings.init()
        settings.proxySettings?.httpEnabled=true
        settings.proxySettings?.httpServer=NEProxyServer.init(address: "127.0.0.1", port: Int.init(defaultServerPort))
        settings.proxySettings?.httpsEnabled=true
        settings.proxySettings?.httpsServer=NEProxyServer.init(address: "127.0.0.1", port: Int.init(defaultServerPort))
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
        exit(0)
    }
}
