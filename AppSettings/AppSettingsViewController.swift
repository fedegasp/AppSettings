//
//  AppSettingsViewController.swift
//  AppSettings
//
//  Created by Federico Gasperini on 08/03/2021.
//

import UIKit

public protocol AppSettingsViewControllerDelegate: class {
    func appSettings(_ vc: AppSettingsViewController, didChange key: String, value: Any?)
}

open class AppSettingsViewController: UITableViewController {
    
    static let title = "Debug menu"
    
    weak var delegate: AppSettingsViewControllerDelegate?
    
    private var filename: String = "Root"
    
    private var context = 0
    
    private var settings = [Group]() {
        didSet {
            for group in oldValue {
                guard let settings = group.settings else { continue }
                for p in settings {
                    if p.key.count > 0 {
                        UserDefaults.standard.removeObserver(self, forKeyPath: p.key)
                    }
                }
            }
            for group in settings {
                guard let settings = group.settings else { continue }
                for p in settings {
                    if p.key.count > 0 {
                        UserDefaults.standard.addObserver(self, forKeyPath: p.key, options: [.new], context: &context)
                    }
                }
            }
        }
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if context == &self.context {
            guard let keyPath = keyPath else { return }
            self.delegate?.appSettings(self, didChange: keyPath, value: UserDefaults.standard.value(forKey: keyPath))
        }
        else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    public class func open(_ file: String? = nil, title: String? = nil, on viewController: UIViewController, delegate: AppSettingsViewControllerDelegate? = nil, completion: (() -> Void)? = nil) {
        
        guard let navController = UIStoryboard(name: "AppSettings", bundle: Bundle(for: self)).instantiateInitialViewController() as? UINavigationController,
              let selfInstance = navController.viewControllers.first as? AppSettingsViewController else {
            return
        }
        
        if let file = file {
            selfInstance.filename = file
        }
        if let title = title {
            selfInstance.title = title
        }
        else {
            selfInstance.title = AppSettingsViewController.title
        }
        selfInstance.delegate = delegate
        
        viewController.present(navController, animated: true, completion: completion)
    }
        
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.settings = loadSettings(in: filename)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(done(_ :)))
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reload()
    }
    
    @objc private func done(_ sender: Any?) {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    open func reload() {
        self.tableView.reloadData()
    }
    
    override open func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        guard let identifier = segue.identifier else { return }
        if case .PSMultiValueSpecifier = SettingType(rawValue: identifier),
           let selection = self.tableView.indexPathForSelectedRow,
           let setting = self.settings[selection.section].settings?[selection.row] {
            (segue.destination as? OptionsTableViewController)?.setting = setting
        }
    }

    // MARK: - Table view data source

    override open func numberOfSections(in tableView: UITableView) -> Int {
        return self.settings.count
    }

    override open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.settings[section].settings?.count ?? 0
    }
    
    override open func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return self.settings[section].title
    }
    
    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return self.settings[section].footer
    }
    
    override open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let setting = settings[indexPath.section].settings?[indexPath.row] else { return UITableViewCell() }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: setting.settingType.rawValue) ?? UITableViewCell()
        cell.textLabel?.text = setting.title
        switch setting.settingType {
        case .PSTitleValueSpecifier:
            cell.detailTextLabel?.text = setting.value as? String
            
        case .PSMultiValueSpecifier:
            cell.detailTextLabel?.text = setting.currentValueTitle
            
        case .PSToggleSwitchSpecifier:
            (cell as? SwitchTableViewCell)?.setting = setting
            
        case .PSTextFieldSpecifier:
            (cell as? TextFieldTableViewCell)?.setting = setting
            
        case .PSSliderSpecifier:
            (cell as? SliderTableViewCell)?.setting = setting
            
        default:
            break
        }
        
        return cell
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let setting = settings[indexPath.section].settings?[indexPath.row] else { return }
        switch setting.settingType {
        case .PSChildPaneSpecifier:
            if let childPane = self.storyboard?.instantiateViewController(withIdentifier: "AppSettingsViewController") as? AppSettingsViewController {
                childPane.filename = setting.value as? String ?? ""
                childPane.delegate = self.delegate
                childPane.title = setting.title
                self.navigationController?.pushViewController(childPane, animated: true)
            }
            
        case .PSButtonSpecifier:
            self.delegate?.appSettings(self, didChange: setting.key, value: nil)
            
        default:
            return
        }
    }
    
    deinit {
        for group in self.settings {
            guard let settings = group.settings else { continue }
            for p in settings {
                if p.key.count > 0 {
                    UserDefaults.standard.removeObserver(self, forKeyPath: p.key)
                }
            }
        }
    }
}
