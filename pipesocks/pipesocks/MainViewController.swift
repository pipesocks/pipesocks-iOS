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
    let notValid=UIAlertController.init(title: "Error", message: "Set the settings before you start pipesocks!", preferredStyle: UIAlertControllerStyle.alert)
    let OKButton=UIAlertAction.init(title: "OK", style: UIAlertActionStyle.default, handler: nil)
    var core:VPNCore?

    override func viewDidLoad() {
        super.viewDidLoad()
        nav.title="pipesocks \(Version.ver)"
        notValid.addAction(OKButton)
        self.start.setBackgroundImage(#imageLiteral(resourceName: "inactive.png"), for: UIControlState.normal)
        core=VPNCore.init(completionHandler: { 
            if self.core?.status()==NEVPNStatus.connected||self.core?.status()==NEVPNStatus.connecting {
                self.start.setBackgroundImage(#imageLiteral(resourceName: "origin.png"), for: UIControlState.normal)
                self.settings.isEnabled=false
            }
        })
    }

    @IBAction func startClicked() {
        core=VPNCore.init(completionHandler: { 
            if self.core?.status()==NEVPNStatus.connected {
                self.core?.stop()
                self.start.setBackgroundImage(#imageLiteral(resourceName: "inactive.png"), for: UIControlState.normal)
                self.settings.isEnabled=true
            } else if self.core?.status()==NEVPNStatus.disconnected {
                self.core?.start()
                self.start.setBackgroundImage(#imageLiteral(resourceName: "origin.png"), for: UIControlState.normal)
                self.settings.isEnabled=false
            } else if self.core?.status()==NEVPNStatus.invalid {
                self.present(self.notValid, animated: true, completion: nil)
            }
        })
    }
}
