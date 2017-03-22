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

import UIKit
import NetworkExtension

class SettingsViewController: UITableViewController {

    @IBOutlet weak var remoteHost: UITextField!
    @IBOutlet weak var remotePort: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var autoMode: UISwitch!
    @IBOutlet weak var enableIPv6: UISwitch!
    var core:VPNCore?
    static var url:String?

    override func viewDidLoad() {
        super.viewDidLoad()
        remotePort.text="7473"
        autoMode.isOn=true
        enableIPv6.isOn=false
        core=VPNCore.init(completionHandler: {
            if self.core?.status() != NEVPNStatus.invalid {
                let config:[String:Any]=(self.core?.getConfig())!
                self.remoteHost.text=config["remoteHost"] as! String?
                self.remotePort.text="\(config["remotePort"] as! UInt16)"
                self.password.text=config["password"] as! String?
                self.autoMode.isOn=config["autoMode"] as! Bool
                self.enableIPv6.isOn=config["enableIPv6"] as! Bool
            }
        })
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if var url=SettingsViewController.url {
            var ok:Bool=false
            if String.init(url.characters.prefix(12))=="pipesocks://" {
                url=urlSafeBase64Decode(str: String.init(url.characters.suffix(url.characters.count-12)))
                let params=url.characters.split(separator: Character.init("|"), maxSplits: 2, omittingEmptySubsequences: false)
                if params.count==3 {
                    remoteHost.text=String.init(params[0])
                    remotePort.text=String.init(params[1])
                    password.text=String.init(params[2])
                    ok=true
                }
            }
            if !ok {
                let notValid=UIAlertController.init(title: "Error", message: "The URL or QR Code is invalid!", preferredStyle: UIAlertControllerStyle.alert)
                let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                notValid.addAction(OKButton)
                present(notValid, animated: true, completion: nil)
            }
            SettingsViewController.url=nil
        }
    }

    @IBAction func remoteHostDone() {
        remotePort.becomeFirstResponder()
    }

    @IBAction func remotePortDone() {
        password.becomeFirstResponder()
    }

    @IBAction func passwordDone() {
        password.resignFirstResponder()
    }

    @IBAction func saveClicked() {
        if remoteHost.text!.isEmpty||remotePort.text!.isEmpty {
            let notFilled=UIAlertController.init(title: "Error", message: "Fill in the blanks!", preferredStyle: UIAlertControllerStyle.alert)
            let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            notFilled.addAction(OKButton)
            present(notFilled, animated: true, completion: nil)
            return
        }
        if UInt16.init(remotePort.text!)==nil {
            let notNum=UIAlertController.init(title: "Error", message: "Please enter a number in Remote Port!", preferredStyle: UIAlertControllerStyle.alert)
            let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
            notNum.addAction(OKButton)
            present(notNum, animated: true, completion: nil)
            return
        }
        let config:[String:Any]=[
            "remoteHost":remoteHost.text!,
            "remotePort":UInt16.init(remotePort.text!)!,
            "password":password.text!,
            "autoMode":autoMode.isOn,
            "enableIPv6":enableIPv6.isOn
        ]
        core?.setConfig(config: config, completionHandler: { (success) in
            if success {
                self.navigationController?.popViewController(animated: true)
            } else {
                let notValid=UIAlertController.init(title: "Error", message: "Permission denied!\nPlease allow the VPN configuration!", preferredStyle: UIAlertControllerStyle.alert)
                let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
                notValid.addAction(OKButton)
                self.present(notValid, animated: true, completion: nil)
            }
        })
    }

    @IBAction func QRCodeClicked() {
        EncodeViewController.url="pipesocks://\(urlSafeBase64Encode(str: "\(remoteHost.text!)|\(remotePort.text!)|\(password.text!)"))"
        performSegue(withIdentifier: "ShowQRCode", sender: self)
    }

    func urlSafeBase64Encode(str:String) -> String {
        return str.data(using: String.Encoding.ascii)!.base64EncodedString().replacingOccurrences(of: "/", with: "_").replacingOccurrences(of: "+", with: "-")
    }

    func urlSafeBase64Decode(str:String) -> String {
        let data:Data?=Data.init(base64Encoded: str.replacingOccurrences(of: "-", with: "+").replacingOccurrences(of: "_", with: "/"))
        if data != nil {
            return String.init(data: data!, encoding: String.Encoding.ascii)!
        } else {
            return String.init()
        }
    }
}
