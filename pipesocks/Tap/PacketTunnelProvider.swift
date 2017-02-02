//
//  PacketTunnelProvider.swift
//  Tap
//
//  Created by Jerry Zhou on 02/2.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import NetworkExtension

class PacketTunnelProvider: NEPacketTunnelProvider {

    var remoteHost:String=""
    var remotePort:UInt16=0
    var password:String=""
    var tcpConnection:NWTCPConnection?

    override func startTunnel(options: [String : NSObject]? = nil, completionHandler: @escaping (Error?) -> Void) {
        let ptc:NETunnelProviderProtocol=protocolConfiguration as! NETunnelProviderProtocol
        remoteHost=ptc.providerConfiguration?["remoteHost"] as! String
        remotePort=ptc.providerConfiguration?["remotePort"] as! UInt16
        password=ptc.providerConfiguration?["password"] as! String
        let settings=NEPacketTunnelNetworkSettings.init(tunnelRemoteAddress: "1.1.1.1")
        settings.iPv4Settings=NEIPv4Settings.init(addresses: ["192.168.98.1"], subnetMasks: ["255.255.255.255"])
        settings.iPv4Settings?.includedRoutes=[NEIPv4Route.default()]
        settings.dnsSettings=NEDNSSettings.init(servers: ["8.8.8.8", "8.8.4.4"])
        settings.tunnelOverheadBytes=150
        settings.mtu=1500
        setTunnelNetworkSettings(settings) { (err) in
            self.tcpConnection=self.createTCPConnection(to: NWHostEndpoint.init(hostname: self.remoteHost, port: "\(self.remotePort)"), enableTLS: false, tlsParameters: nil, delegate: nil)
            self.packetFlow.readPackets { (packets, protocols) in
                self.handlePackets(packets: packets, protocols: protocols)
            }
            completionHandler(err)
        }
    }

    override func stopTunnel(with reason: NEProviderStopReason, completionHandler: @escaping () -> Void) {
        tcpConnection?.writeClose()
        completionHandler()
    }

    func handlePackets(packets: [Data], protocols: [NSNumber]) {
        for packet in packets {
            tcpConnection?.write(packet, completionHandler: { (err) in})
        }
        packetFlow.readPackets { (packets, protocols) in
            self.handlePackets(packets: packets, protocols: protocols)
        }
    }
}
