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
    let notValid=UIAlertController.init(title: "Error", message: "Permission denied!\nPlease restart pipesocks and allow the VPN configuration!", preferredStyle: UIAlertControllerStyle.alert)
    let notFilled=UIAlertController.init(title: "Error", message: "Fill in the blanks!", preferredStyle: UIAlertControllerStyle.alert)
    let notNum=UIAlertController.init(title: "Error", message: "Please enter a number in Remote Port!", preferredStyle: UIAlertControllerStyle.alert)
    let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
    let settings=UserDefaults.init()
    let core=VPNCore.init()

    override func viewDidLoad() {
        super.viewDidLoad()
        notValid.addAction(OKButton)
        notFilled.addAction(OKButton)
        notNum.addAction(OKButton)
        titleLabel.text="pipesocks \(ver)"
        if settings.string(forKey: "remoteHost") != nil {
            remoteHost.text=settings.string(forKey: "remoteHost")
            remotePort.text=settings.string(forKey: "remotePort")
            password.text=settings.string(forKey: "password")
        }
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
            if !core.isValid() {
                present(notValid, animated: true, completion: nil)
                return
            }
            if remoteHost.text==""||remotePort.text=="" {
                present(notFilled, animated: true, completion: nil)
                return
            }
            if UInt16(remotePort.text!)==nil {
                present(notNum, animated: true, completion: nil)
                return
            }
            settings.set(remoteHost.text, forKey: "remoteHost")
            settings.set(remotePort.text, forKey: "remotePort")
            settings.set(password.text, forKey: "password")
            startButton.setTitle("Stop", for: UIControlState.normal)
            remoteHost.isEnabled=false
            remotePort.isEnabled=false
            password.isEnabled=false
            titleLabel.text="Enjoy!"
            core.start()
        } else if startButton.titleLabel?.text=="Stop" {
            startButton.setTitle("Start", for: UIControlState.normal)
            remoteHost.isEnabled=true
            remotePort.isEnabled=true
            password.isEnabled=true
            titleLabel.text="pipesocks \(ver)"
            core.stop()
        }
    }
}

