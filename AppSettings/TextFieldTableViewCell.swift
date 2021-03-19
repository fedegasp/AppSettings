//
//  TextFieldTableViewCell.swift
//  AppSettings
//
//  Created by Federico Gasperini on 18/03/2021.
//

import UIKit

class TextFieldTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textField: UITextField? {
        didSet {
            oldValue?.removeTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
            self.textField?.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        }
    }
    @IBOutlet weak var label: UILabel?

    var setting: Setting? {
        didSet {
            self.handleValue()
        }
    }
    
    @objc func textChanged(_ sender: UITextField?) {
        self.setting?.value = sender?.text as AnyObject
    }

    func handleValue() {
        self.textField?.text = self.setting?.value as? String
        if let type = self.setting?.keyboardType?.getType() {
            self.textField?.keyboardType = type
        }
        self.textField?.isSecureTextEntry = self.setting?.isSecure ?? false
    }

    override var textLabel: UILabel? {
        return self.label
    }
}

extension KeyboardType {
    func getType() -> UIKeyboardType {
        switch self {
        case .Alphabet:
            return .alphabet
            
        case .EmailAddress:
            return .emailAddress
            
        case .NumberPad:
            return .numberPad
            
        case .NumbersAndPunctuation:
            return .numbersAndPunctuation
            
        case .URL:
            return .URL
        }
    }
}
