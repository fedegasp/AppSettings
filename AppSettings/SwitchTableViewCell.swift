//
//  SwitchTableViewCell.swift
//  AppSettings
//
//  Created by Federico Gasperini on 08/03/2021.
//

import UIKit

class SwitchTableViewCell: UITableViewCell {
    
    @IBOutlet var label: UILabel?
    @IBOutlet var switchComponent: UISwitch? {
        didSet {
            switchComponent?.addTarget(self, action: #selector(onChange(_:)), for: .valueChanged)
            handleSwitch()
        }
    }
    var setting: Setting? {
        didSet {
            handleSwitch()
        }
    }
    
    private func handleSwitch() {
        self.switchComponent?.isOn = self.setting?.value as? Bool ?? false
    }
    
    @objc func onChange(_ sender: UISwitch) {
        self.setting?.value = sender.isOn as AnyObject
    }
    
    override var textLabel: UILabel? {
        get {
            self.label
        }
    }
}
