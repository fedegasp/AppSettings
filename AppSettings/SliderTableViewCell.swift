//
//  SliderTableViewCell.swift
//  AppSettings
//
//  Created by Federico Gasperini on 19/03/2021.
//

import UIKit

class SliderTableViewCell: UITableViewCell {

    @IBOutlet var slider: UISlider? {
        didSet {
            oldValue?.removeTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
            self.slider?.addTarget(self, action: #selector(valueChanged(_:)), for: .valueChanged)
        }
    }
    
    var setting: Setting? {
        didSet {
            self.handleSetting()
        }
    }
    
    @objc func valueChanged(_ sender: UISlider) {
        self.setting?.value = sender.value as AnyObject
    }

    func handleSetting() {
        self.slider?.maximumValue = self.setting?.maxValue ?? 0
        self.slider?.minimumValue = self.setting?.minValue ?? 0
        self.slider?.value = self.setting?.value as? Float ?? 0
    }
}
