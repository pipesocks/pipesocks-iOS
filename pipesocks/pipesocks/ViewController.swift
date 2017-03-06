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

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var remoteHost: UITextField!
    @IBOutlet weak var remotePort: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var aboutLabel: UILabel!

    let ver:String=Version.ver
    let notFilled=UIAlertController.init(title: "Error", message: "Fill in the blanks!", preferredStyle: UIAlertControllerStyle.alert)
    let notNum=UIAlertController.init(title: "Error", message: "Please enter a number in Remote Port!", preferredStyle: UIAlertControllerStyle.alert)
    let notValid=UIAlertController.init(title: "Error", message: "Permission denied!\nPlease allow the VPN configuration!", preferredStyle: UIAlertControllerStyle.alert)
    let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
    var core:VPNCore?

    override func viewDidLoad() {
        super.viewDidLoad()
        notFilled.addAction(OKButton)
        notNum.addAction(OKButton)
        notValid.addAction(OKButton)
        titleLabel.text="pipesocks \(ver)"
        aboutLabel.adjustsFontSizeToFitWidth=true
        core=VPNCore.init(completionHandler: { (config, started) in
            if config != nil {
                self.remoteHost.text=config?["remoteHost"] as! String?
                self.remotePort.text="\(config?["remotePort"] as! UInt16)"
                self.password.text=config?["password"] as! String?
            }
            if started {
                self.startClicked()
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
    
    @IBAction func startClicked() {
        if startButton.titleLabel?.text=="Start" {
            if remoteHost.text==""||remotePort.text=="" {
                present(notFilled, animated: true, completion: nil)
                return
            }
            if UInt16(remotePort.text!)==nil {
                present(notNum, animated: true, completion: nil)
                return
            }
            core?.start(remoteHost: remoteHost.text!, remotePort: UInt16(remotePort.text!)!, password: password.text!, completionHandler: { (success) in
                if success {
                    self.startButton.setTitle("Stop", for: UIControlState.normal)
                    self.remoteHost.isEnabled=false
                    self.remotePort.isEnabled=false
                    self.password.isEnabled=false
                    self.titleLabel.text="Enjoy!"
                } else {
                    self.present(self.notValid, animated: true, completion: nil)
                }
            })
        } else if startButton.titleLabel?.text=="Stop" {
            core?.stop()
            startButton.setTitle("Start", for: UIControlState.normal)
            remoteHost.isEnabled=true
            remotePort.isEnabled=true
            password.isEnabled=true
            titleLabel.text="pipesocks \(ver)"
        }
    }
}
