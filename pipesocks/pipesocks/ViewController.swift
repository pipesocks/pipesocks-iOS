//
//  ViewController.swift
//  pipesocks
//
//  Created by Jerry Zhou on 01/31.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var remoteHost: UITextField!
    @IBOutlet weak var remotePort: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var startButton: UIButton!

    let ver:String=Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")! as! String
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

