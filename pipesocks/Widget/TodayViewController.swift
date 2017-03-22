//
//  TodayViewController.swift
//  Widget
//
//  Created by Jerry Zhou on 03/22.
//  Copyright © 2017 yvbbrjdr. All rights reserved.
//

import UIKit
import NotificationCenter
import NetworkExtension

class TodayViewController: UIViewController, NCWidgetProviding {

    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var start: UISwitch!
    var core:VPNCore?

    override func viewDidLoad() {
        super.viewDidLoad()
        update()
    }

    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        update()
        completionHandler(NCUpdateResult.newData)
    }

    func update() {
        core=VPNCore.init(completionHandler: {
            let config=self.core!.getConfig()
            switch self.core!.status() {
                case .connected, .connecting, .reasserting:
                    self.label.text="Remote Host: \(config!["remoteHost"] as! String)\nRemote Port: \(config!["remotePort"] as! UInt16)\nPassword: \(config!["password"] as! String)"
                    self.start.isOn=true
                    self.start.isEnabled=true
                    break
                case .disconnected, .disconnecting:
                    self.label.text="Remote Host: \(config!["remoteHost"] as! String)\nRemote Port: \(config!["remotePort"] as! UInt16)\nPassword: \(config!["password"] as! String)"
                    self.start.isOn=false
                    if self.core!.manager!.isEnabled {
                        self.start.isEnabled=true
                    } else {
                        self.start.isEnabled=false
                    }
                    break
                case .invalid:
                    self.label.text="Open pipesocks to setup."
                    self.start.isOn=false
                    self.start.isEnabled=false
                    break
            }
        })
    }

    @IBAction func startClicked() {
        if start.isOn {
            core!.start()
        } else {
            core!.stop()
        }
    }
}
