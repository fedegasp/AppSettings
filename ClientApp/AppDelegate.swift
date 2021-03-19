//
//  AppDelegate.swift
//  ClientApp
//
//  Created by Federico Gasperini on 08/03/2021.
//

import UIKit

extension String {
    var lastPathComponent: String {
        return (self as NSString).lastPathComponent
    }
}

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerDefaultsFromSettingsBundle()
        return true
    }

    private func registerDefaultsFromSettingsBundle() {
        guard let settingsBundle = Bundle.main.path(forResource: "Settings", ofType: "bundle"),
            let dirFiles = try? FileManager.default.contentsOfDirectory(atPath: settingsBundle) else {
                print("registerDefaultsFromSettingsBundle: Could not find Settings.bundle")
                return
        }
        
        let defs = UserDefaults.standard;
        
        let plistPaths = dirFiles.filter { (path) -> Bool in
            path.hasSuffix(".plist")
        }
        let plists = plistPaths.map { $0.lastPathComponent }
        
        var defaultsToRegister = [String : Any]()
        
        for file in plists {
            print("Set default from \(file)")
            
            if let settings = NSDictionary(contentsOf: URL(fileURLWithPath: settingsBundle).appendingPathComponent(file)),
                let preferences = settings["PreferenceSpecifiers"] as? [AnyObject] {
                
                for prefSpecificationMap in preferences {
                    if let prefSpecification = prefSpecificationMap as? [String : Any] {
                        if let key = prefSpecification["Key"] as? String {
                            // check if value readable in userDefaults
                            if defs.object(forKey: key) == nil {
                                // not readable: set value from Settings.bundle
                                if let objectToSet = prefSpecification["DefaultValue"] {
                                    defaultsToRegister[key] = objectToSet
                                    print("Setting object \(objectToSet) for key \(key)")
                                }
                            }
                        }
                    }
                }
            }
        }
        
        if defaultsToRegister.count > 0 {
            print("Registering default values from Settings.bundle")
            defs.register(defaults: defaultsToRegister)
            defs.synchronize()
        }
    }

}

