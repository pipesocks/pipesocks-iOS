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

class MainViewController: UIViewController {

    @IBOutlet weak var nav: UINavigationItem!
    @IBOutlet weak var start: UIButton!
    @IBOutlet weak var settings: UIBarButtonItem!
    
    var core:VPNCore?

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        nav.title="pipesocks \(Version.getHighestVersion())"
        core=VPNCore.init(completionHandler: {
            self.stateChanged()
            if self.core!.status() != .invalid {
                NotificationCenter.default.addObserver(forName: NSNotification.Name.NEVPNStatusDidChange, object: self.core?.manager?.connection, queue: OperationQueue.main, using: { (notification) in
                    self.stateChanged()
                })
            }
        })
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if core!.status() != .invalid {
            NotificationCenter.default.removeObserver(self, name: NSNotification.Name.NEVPNStatusDidChange, object: core?.manager?.connection)
        }
    }

    func stateChanged() {
        switch core!.status() {
            case .connected:
                start.setBackgroundImage(#imageLiteral(resourceName: "origin.png"), for: UIControlState.normal)
                start.isEnabled=true
                settings.isEnabled=false
                break
            case .connecting, .reasserting:
                start.setBackgroundImage(#imageLiteral(resourceName: "origin.png"), for: UIControlState.normal)
                start.isEnabled=false
                settings.isEnabled=false
                break
            case .invalid, .disconnected:
                start.setBackgroundImage(#imageLiteral(resourceName: "inactive.png"), for: UIControlState.normal)
                start.isEnabled=true
                settings.isEnabled=true
                break
            case .disconnecting:
                start.setBackgroundImage(#imageLiteral(resourceName: "inactive.png"), for: UIControlState.normal)
                start.isEnabled=false
                settings.isEnabled=false
                break
        }
    }

    @IBAction func startClicked() {
        switch core!.status() {
            case .connected:
                core?.stop()
                break
            case .disconnected:
                core?.start()
                break
            case .invalid:
                let notValid=UIAlertController.init(title: "Error", message: "Set the settings before you start pipesocks!", preferredStyle: UIAlertControllerStyle.alert)
                let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default) { (action) in
                    self.performSegue(withIdentifier: "ShowSettings", sender: self)
                }
                notValid.addAction(OKButton)
                present(notValid, animated: true, completion: nil)
                break
            default:
                break
        }
    }
}
