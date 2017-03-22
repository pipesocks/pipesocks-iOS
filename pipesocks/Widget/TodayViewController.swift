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
