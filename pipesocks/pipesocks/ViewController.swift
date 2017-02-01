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

    let ver=Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")!
    let notFilled=UIAlertController.init(title: "Error", message: "Fill in the blanks!", preferredStyle: UIAlertControllerStyle.alert)
    let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        notFilled.addAction(OKButton)
        titleLabel.text="pipesocks \(ver)"
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
            if !(remoteHost.text==""||remotePort.text=="") {
                startButton.setTitle("Stop", for: UIControlState.normal)
                remoteHost.isEnabled=false
                remotePort.isEnabled=false
                password.isEnabled=false
                titleLabel.text="Enjoy!"
            } else {
                present(notFilled, animated: true, completion: nil)
            }
        } else if startButton.titleLabel?.text=="Stop" {
            startButton.setTitle("Start", for: UIControlState.normal)
            remoteHost.isEnabled=true
            remotePort.isEnabled=true
            password.isEnabled=true
            titleLabel.text="pipesocks \(ver)"
        }
    }
}

