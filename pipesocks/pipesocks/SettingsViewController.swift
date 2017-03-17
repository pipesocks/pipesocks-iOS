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

class SettingsViewController: UITableViewController {

    @IBOutlet weak var remoteHost: UITextField!
    @IBOutlet weak var remotePort: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var autoMode: UISwitch!
    @IBOutlet weak var enableIPv6: UISwitch!

    override func viewDidLoad() {
        super.viewDidLoad()
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
        
    }
}
