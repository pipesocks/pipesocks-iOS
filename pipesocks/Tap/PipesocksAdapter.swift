//
//  PipesocksAdapter.swift
//  pipesocks
//
//  Created by Jerry Zhou on 02/26.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import Foundation
import NEKit
import Sodium

class PipesocksAdapter: AdapterSocket {

    enum PipesocksAdapterStatus {
        case idle,
        connecting,
        connected,
        keyexchanged,
        forwarding,
        disconnected
    }
    var internalStatus:PipesocksAdapterStatus = .idle

    var remoteHost:String=""
    var remotePort:UInt16=0
    var password:String=""
    var secretKey:Data?
    var localPubKey:Data?
    var localPriKey:Data?
    var remotePubKey:Data?
    var recvBuffer:Data=Data.init()

    init(remoteHost: String, remotePort: UInt16, password: String) {
        super.init()
        self.remoteHost=remoteHost
        self.remotePort=remotePort
        self.password=password
        localPubKey=Data.init(count: Int.init(crypto_box_PUBLICKEYBYTES))
        localPriKey=Data.init(count: Int.init(crypto_box_SECRETKEYBYTES))
        if sodium_init() == -1 {
            exit(1)
        }
        localPubKey!.withUnsafeMutableBytes { (localPubKey: UnsafeMutablePointer<UInt8>) -> Void in
            localPriKey!.withUnsafeMutableBytes({ (localPriKey: UnsafeMutablePointer<UInt8>) -> Void in
                crypto_box_keypair(localPubKey, localPriKey)
            })
        }
        secretKey=password.data(using: String.Encoding.ascii)
        if secretKey!.count>=Int.init(crypto_secretbox_KEYBYTES) {
            secretKey=prefix(data: secretKey!, n: Int.init(crypto_secretbox_KEYBYTES))
        } else {
            secretKey!.append(Data.init(bytes: Array<UInt8>.init(repeating: UInt8.init(0x98), count: Int.init(crypto_secretbox_KEYBYTES)-secretKey!.count)))
        }
    }

    public override func openSocketWith(session: ConnectSession) {
        super.openSocketWith(session: session)
        guard !isCancelled else {
            return
        }
        internalStatus = .connecting
        try! socket.connectTo(host: remoteHost, port: Int.init(remotePort), enableTLS: false, tlsSettings: nil)
    }

    public override func didConnectWith(socket: RawTCPSocketProtocol) {
        super.didConnectWith(socket: socket)
        internalStatus = .connected
        sendPubKey()
        socket.readData()
    }

    public override func didRead(data: Data, from socket: RawTCPSocketProtocol) {
        super.didRead(data: data, from: socket)
        recvBuffer.append(data)
        while recvBuffer.count>=Int.init(crypto_secretbox_MACBYTES)+4+Int.init(crypto_secretbox_NONCEBYTES) {
            let prefix:Data=secretDecrypt(data: self.prefix(data: recvBuffer, n: Int.init(crypto_secretbox_MACBYTES)+4+Int.init(crypto_secretbox_NONCEBYTES)))
            if prefix.count==0 {
                return
            }
            var l:UInt32=UInt32.init(prefix[0])
            l=(l<<8)+UInt32.init(prefix[1])
            l=(l<<8)+UInt32.init(prefix[2])
            l=(l<<8)+UInt32.init(prefix[3])
            if recvBuffer.count<Int.init(l) {
                break
            }
            var segment:Data=suffix(data: self.prefix(data: recvBuffer, n: Int.init(l)), from: Int.init(crypto_secretbox_MACBYTES)+4+Int.init(crypto_secretbox_NONCEBYTES))
            recvBuffer=suffix(data: recvBuffer, from: Int.init(l))
            if remotePubKey==nil {
                segment=secretDecrypt(data: segment)
            } else {
                segment=publicDecrypt(data: segment)
            }
            process(data: segment)
        }
        socket.readData()
    }

    override open func didWrite(data: Data?, by socket: RawTCPSocketProtocol) {
        super.didWrite(data: data, by: socket)
        if internalStatus == .forwarding {
            delegate?.didWrite(data: data, by: self)
        }
    }

    override func write(data: Data) {
        sendUnencrypted(data: data)
    }

    func write(rawData: Data) {
        super.write(data: rawData)
    }

    func process(data: Data) {
        switch internalStatus {
        case .connected:
            if data.count<Int.init(crypto_box_PUBLICKEYBYTES) {
                disconnect()
                internalStatus = .disconnected
                return
            }
            remotePubKey=suffix(data: data, n: Int.init(crypto_box_PUBLICKEYBYTES))
            let request:NSDictionary=[
                "host":session.host,
                "port":session.port,
                "password":password,
                "version":Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")! as! String,
                "protocol":"TCP"
            ]
            try! write(data: JSONSerialization.data(withJSONObject: request))
            internalStatus = .keyexchanged
            break
        case .keyexchanged:
            let response:NSDictionary=try! JSONSerialization.jsonObject(with: data) as! NSDictionary
            if response["status"]! as! String != "ok" {
                disconnect()
                internalStatus = .disconnected
                return
            }
            delegate?.didBecomeReadyToForwardWith(socket: self)
            internalStatus = .forwarding
            break
        case .forwarding:
            delegate?.didRead(data: data, from: self)
            break
        default:
            break
        }
    }

    func sendEncrypted(data: Data) {
        let l:UInt32=crypto_secretbox_MACBYTES+4+crypto_secretbox_NONCEBYTES+UInt32.init(data.count)
        let prefix:Data=Data.init(bytes: [UInt8.init(l>>24&0xff),UInt8.init(l>>16&0xff),UInt8.init(l>>8&0xff),UInt8.init(l&0xff)])
        var ret:Data=secretEncrypt(data: prefix)
        ret.append(data)
        write(rawData: ret)
    }

    func sendPubKey() {
        let l:Int=Int.init(randombytes_uniform(900))
        var garbage:Data=Data.init(count: l)
        garbage.withUnsafeMutableBytes { (garbage: UnsafeMutablePointer<UInt8>) -> Void in
            randombytes_buf(garbage, l)
        }
        garbage.append(localPubKey!)
        sendEncrypted(data: secretEncrypt(data: garbage))
    }

    func sendUnencrypted(data: Data) {
        sendEncrypted(data: publicEncrypt(data: data))
    }

    func publicEncrypt(data: Data) -> Data {
        var ret:Data=Data.init(count: Int.init(crypto_box_MACBYTES)+data.count)
        var nonce:Data=Data.init(count: Int.init(crypto_box_NONCEBYTES))
        nonce.withUnsafeMutableBytes { (nonce: UnsafeMutablePointer<UInt8>) -> Void in
            randombytes_buf(nonce, Int.init(crypto_box_NONCEBYTES))
        }
        let result:Int32=ret.withUnsafeMutableBytes { (ret: UnsafeMutablePointer<UInt8>) -> Int32 in
            return data.withUnsafeBytes({ (dataPtr: UnsafePointer<UInt8>) -> Int32 in
                return nonce.withUnsafeBytes({ (nonce: UnsafePointer<UInt8>) -> Int32 in
                    return remotePubKey!.withUnsafeBytes({ (remotePubKey: UnsafePointer<UInt8>) -> Int32 in
                        return localPriKey!.withUnsafeBytes({ (localPriKey: UnsafePointer<UInt8>) -> Int32 in
                            return crypto_box_easy(ret, dataPtr, UInt64.init(data.count), nonce, remotePubKey, localPriKey)
                        })
                    })
                })
            })
        }
        if result==0 {
            ret.append(nonce)
            return ret
        }
        disconnect()
        internalStatus = .disconnected
        return Data.init()
    }

    func publicDecrypt(data: Data) -> Data {
        var ret:Data=Data.init(count: data.count-Int.init(crypto_box_MACBYTES)-Int.init(crypto_box_NONCEBYTES))
        let encrypted:Data=prefix(data: data, n: data.count-Int.init(crypto_box_NONCEBYTES))
        let nonce:Data=suffix(data: data, n: Int.init(crypto_box_NONCEBYTES))
        let result:Int32=ret.withUnsafeMutableBytes { (ret: UnsafeMutablePointer<UInt8>) -> Int32 in
            return encrypted.withUnsafeBytes({ (encryptedPtr: UnsafePointer<UInt8>) -> Int32 in
                return nonce.withUnsafeBytes({ (nonce: UnsafePointer<UInt8>) -> Int32 in
                    return remotePubKey!.withUnsafeBytes({ (remotePubKey: UnsafePointer<UInt8>) -> Int32 in
                        return localPriKey!.withUnsafeBytes({ (localPriKey: UnsafePointer<UInt8>) -> Int32 in
                            return crypto_box_open_easy(ret, encryptedPtr, UInt64.init(encrypted.count), nonce, remotePubKey, localPriKey)
                        })
                    })
                })
            })
        }
        if result==0 {
            return ret
        }
        disconnect()
        internalStatus = .disconnected
        return Data.init()
    }

    func secretEncrypt(data: Data) -> Data {
        var ret:Data=Data.init(count: Int.init(crypto_secretbox_MACBYTES)+data.count)
        var nonce:Data=Data.init(count: Int.init(crypto_secretbox_NONCEBYTES))
        nonce.withUnsafeMutableBytes { (nonce: UnsafeMutablePointer<UInt8>) -> Void in
            randombytes_buf(nonce, Int.init(crypto_secretbox_NONCEBYTES))
        }
        let result:Int32=ret.withUnsafeMutableBytes { (ret: UnsafeMutablePointer<UInt8>) -> Int32 in
            return data.withUnsafeBytes({ (dataPtr: UnsafePointer<UInt8>) -> Int32 in
                return nonce.withUnsafeBytes({ (nonce: UnsafePointer<UInt8>) -> Int32 in
                    return secretKey!.withUnsafeBytes({ (secretKey: UnsafePointer<UInt8>) -> Int32 in
                        return crypto_secretbox_easy(ret, dataPtr, UInt64.init(data.count), nonce, secretKey)
                    })
                })
            })
        }
        if result==0 {
            ret.append(nonce)
            return ret
        }
        disconnect()
        internalStatus = .disconnected
        return Data.init()
    }

    func secretDecrypt(data: Data) -> Data {
        var ret:Data=Data.init(count: data.count-Int.init(crypto_secretbox_MACBYTES)-Int.init(crypto_secretbox_NONCEBYTES))
        let encrypted:Data=prefix(data: data, n: data.count-Int.init(crypto_secretbox_NONCEBYTES))
        let nonce:Data=suffix(data: data, n: Int.init(crypto_secretbox_NONCEBYTES))
        let result:Int32=ret.withUnsafeMutableBytes { (ret: UnsafeMutablePointer<UInt8>) -> Int32 in
            return encrypted.withUnsafeBytes({ (encryptedPtr: UnsafePointer<UInt8>) -> Int32 in
                return nonce.withUnsafeBytes({ (nonce: UnsafePointer<UInt8>) -> Int32 in
                    return secretKey!.withUnsafeBytes({ (secretKey: UnsafePointer<UInt8>) -> Int32 in
                        return crypto_secretbox_open_easy(ret, encryptedPtr, UInt64.init(encrypted.count), nonce, secretKey)
                    })
                })
            })
        }
        if result==0 {
            return ret
        }
        disconnect()
        internalStatus = .disconnected
        return Data.init()
    }

    func prefix(data: Data, n: Int) -> Data {
        return data.subdata(in: data.startIndex..<data.index(data.startIndex, offsetBy: n))
    }

    func suffix(data: Data, n: Int) -> Data {
        return data.subdata(in: data.index(data.endIndex, offsetBy: -n)..<data.endIndex)
    }

    func suffix(data: Data, from: Int) ->Data {
        return data.subdata(in: data.index(data.startIndex, offsetBy: from)..<data.endIndex)
    }
}
