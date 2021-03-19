//
//  Settings.swift
//  AppSettings
//
//  Created by Federico Gasperini on 08/03/2021.
//

import Foundation

enum KeyboardType: String {
    case Alphabet
    case NumbersAndPunctuation
    case NumberPad
    case URL
    case EmailAddress
}

enum SettingType: String {
    case PSTitleValueSpecifier
    case PSChildPaneSpecifier
    case PSToggleSwitchSpecifier
    case PSGroupSpecifier
    case PSMultiValueSpecifier
    case PSTextFieldSpecifier
    case PSSliderSpecifier
    
    // only in-app, iOS is ignoring (iOS 13)
    case PSButtonSpecifier
}

typealias Key = String

extension Key {
    static let PreferenceSpecifiers = "PreferenceSpecifiers"
    static let kType = "Type"
    static let Title = "Title"
    static let Footer = "FooterText"
    static let Key = "Key"
    static let DefaultValue = "DefaultValue"
    static let File = "File"
    static let Titles = "Titles"
    static let Values = "Values"
    static let KeyboardType = "KeyboardType"
    static let IsSecure = "IsSecure"
    static let MaximumValue = "MaximumValue"
    static let MinimumValue = "MinimumValue"
}

protocol SettingProtocol {
    var title: String { get set }
    var key: String { get set }
    var settingType: SettingType { get set }
}

private func emit(_ item: [Key:AnyObject]) -> SettingProtocol? {
    let title = item[.Title] as? String ?? ""
    guard let type = item[Key.kType] as? String,
          let settingType = SettingType(rawValue: type) else {
        return nil
    }
    
    guard let key = item[.Key] as? String else {
        switch settingType {
        case .PSGroupSpecifier:
            return Group(title: title, footer: item[.Footer] as? String, settingType: settingType)
            
        case .PSChildPaneSpecifier:
            guard let child = item[.File] as? String else {
                return nil
            }
            return Setting(title: title, defaultValue: child as AnyObject, settingType: settingType)
            
        default:
            break
        }
        return nil
    }
    
    switch settingType {
    case .PSButtonSpecifier:
        return Setting(title: title, key: key, defaultValue: "" as AnyObject, settingType: settingType)
            
    case .PSChildPaneSpecifier:
        guard let child = item[.File] as? String else {
            return nil
        }
        return Setting(title: title, key: key, defaultValue: child as AnyObject, settingType: settingType)
        
    case .PSGroupSpecifier:
        return Group(title: title, key: key, footer: item[.Footer] as? String, settingType: settingType)
        
    case .PSTitleValueSpecifier,
         .PSToggleSwitchSpecifier,
         .PSTextFieldSpecifier:
        let kt: KeyboardType?
        if let ktstring = item[.KeyboardType] as? String {
            kt = KeyboardType(rawValue: ktstring)
        }
        else {
            kt = nil
        }
        return Setting(title: title, key: key, defaultValue: item[.DefaultValue],
                       settingType: settingType, keyboardType: kt,
                       isSecure: item[.IsSecure] as? Bool ?? false)
        
    case .PSMultiValueSpecifier:
        guard let titles = item[.Titles] as? [String],
              let values = item[.Values] as? [AnyObject],
              titles.count == values.count else {
            return nil
        }
        return Setting(title: title, key: key, defaultValue: item[.DefaultValue], settingType: settingType,
                       titles: titles, values: values)
    
    case .PSSliderSpecifier:
        let defaultValue = item[.DefaultValue] ?? (Float(0.0) as AnyObject)
        let minValue = (item[.MinimumValue] as? Float) ?? Float(0.0)
        let maxValue = (item[.MaximumValue] as? Float) ?? Float(0.0)
        return Setting(title: title, key: key, defaultValue: defaultValue, settingType: settingType, minValue: minValue, maxValue: maxValue)
    }
}

struct Setting: SettingProtocol {
    var title: String
    var key: String = ""
    var defaultValue: AnyObject?
    var value: AnyObject? {
        get {
            return UserDefaults.standard.value(forKey: self.key) as AnyObject? ?? defaultValue
        }
        set {
            if self.key.count > 0 {
                UserDefaults.standard.setValue(newValue, forKey: self.key)
            }
        }
    }
    var settingType: SettingType
    var titles: [String]?
    var values: [AnyObject]?
    var currentValueTitle: String? {
        if let v = self.value ?? self.defaultValue,
           let index = self.values?.firstIndex(where: { $0 === v }) {
            return self.titles?[index]
        }
        return nil
    }
    var keyboardType: KeyboardType?
    var isSecure = false
    
    var minValue: Float = 0
    var maxValue: Float = 0
}

struct Group: SettingProtocol {
    var title: String
    var key: String = ""
    var footer: String?
    var settingType: SettingType
    var settings: [Setting]?
}

func loadSettings(in file: String = "Root") -> [Group] {
    
    guard let bundlePath = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
          let settingsBundle = Bundle(path: bundlePath),
          let plistPath = settingsBundle.path(forResource: file, ofType: "plist"),
          let list = read(plist: plistPath) else {
        return []
    }
    
    var settings = [Setting]()
    var result = [Group]()
    var group: Group?
    
    for dict in list {
        if let item = emit(dict) {
            if let item = item as? Group {
                if group == nil {
                    group = Group(title: "", key: "", footer: nil, settingType: .PSGroupSpecifier, settings: nil)
                }
                group!.settings = settings
                result.append(group!)
                group = item
                settings = []
            }
            else if let setting = item as? Setting {
                settings.append(setting)
            }
        }
    }
    
    if group == nil {
        group = Group(title: "", key: "", footer: nil, settingType: .PSGroupSpecifier, settings: nil)
    }
    
    group?.settings = settings
    result.append(group!)
    
    return result
}

func read(plist path: String) -> [[Key:AnyObject]]? {
    var propertyListFormat =  PropertyListSerialization.PropertyListFormat.xml
    guard let plistXML = FileManager.default.contents(atPath: path) else {
        return nil
    }
    
    do {
        let plistData = try PropertyListSerialization.propertyList(from: plistXML, options: .mutableContainersAndLeaves, format: &propertyListFormat) as? [String:AnyObject]
        return plistData?[Key.PreferenceSpecifiers] as? [[Key:AnyObject]]
    }
    catch {
        print("Error reading plist: \(error), format: \(propertyListFormat)")
    }
    return nil
}
